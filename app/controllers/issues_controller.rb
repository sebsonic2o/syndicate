class IssuesController < ApplicationController
  def index
    @issues = Issue.all
  end

  def show
    @current_issue = Issue.find(params[:id])
    p @current_issue
  end

  def vote
    # p "Got here!"
    # p params
    @current_issue = Issue.find(params[:id])
    @vote = current_user.votes.find_by(issue_id: params[:id])

    if @vote.root?
      @vote.update_attributes(value: params[:value])
      @vote.save

      @vote.descendants.each do |vote|
        vote.value = @vote.value
        vote.save
      end

      base_uri = ENV['FIREBASE_URL']

      firebase = Firebase::Client.new(base_uri)

      response = firebase.push("votes", {
        participant_count: @current_issue.participant_count,
        yes_votes: @current_issue.yes_votes,
        no_votes: @current_issue.no_votes,
        yes_percentage: @current_issue.yes_percentage,
        no_percentage: @current_issue.no_percentage,
        vote_count: @current_issue.vote_count,
        abstain_count: @current_issue.abstain_count
      })
    else
      puts "User has delegated their vote."
    end

    render json: {}
    # render json: {
    #   participant_count: @current_issue.participant_count,
    #   yes_votes: @current_issue.yes_votes,
    #   no_votes: @current_issue.no_votes,
    #   yes_percentage: @current_issue.yes_percentage,
    #   no_percentage: @current_issue.no_percentage,
    #   vote_count: @current_issue.vote_count,
    #   abstain_count: @current_issue.abstain_count
    # }
  end

  def clear
    @current_issue = Issue.find(params[:id])
    p @all_votes = @current_issue.votes
    @all_votes.each do |vote|
      vote.ancestry = nil
      vote.value = "abstain"
      p vote.save
    end
    base_uri = ENV['FIREBASE_URL']
    firebase = Firebase::Client.new(base_uri)

    # need to push
    response = firebase.delete("delegates")
    response = firebase.delete("votes")
  end

  def delegate
    @target_representative = User.find(params[:id])
    @target_representative_vote = @target_representative.votes.find_by(issue_id: params[:issue_id])
    @current_user = current_user
    @current_user_vote = @current_user.votes.find_by(issue_id: params[:issue_id])

 # Firebase Ruby Connection Setup
    base_uri = ENV['FIREBASE_URL']
    firebase = Firebase::Client.new(base_uri)



   # Undelegates vote of current user by clicking on yourself
    if @current_user == @target_representative
      puts "Undelegates vote of current user BY CLICKING ON SELF"

      @old_representative_vote = @current_user_vote.root
      @old_representative = User.find(@old_representative_vote.user_id)

      @current_user_vote.parent = nil
      @current_user_vote.save

      response = firebase.push("delegates", {
        :incident => "undelegate",
        :old_delegate_count => @old_representative_vote.subtree.count,
        :old_delegate_id => @old_representative.id,
        :current_user_count => @current_user_vote.subtree.count,
        :current_user_id => @current_user.id
        })

    # Undelegates vote of current user by clicking on the rep
    elsif @current_user_vote.parent == @target_representative_vote
      puts "Undelegates vote of current user"
      @old_representative_vote = @current_user_vote.root
      @old_representative = User.find(@old_representative_vote.user_id)

      @current_user_vote.parent = nil
      @current_user_vote.save

      response = firebase.push("delegates", {
        :incident => "undelegate",
        :old_delegate_count => @old_representative_vote.subtree.count,
        :old_delegate_id => @old_representative.id,
        :current_user_count => @current_user_vote.subtree.count,
        :current_user_id => @current_user.id})

    # Redelegates current user's vote to a new parent
    elsif !@current_user_vote.root? && @current_user_vote.parent != @target_representative_vote

      puts "Redelegates current user's vote to a new parent"
      @old_root_vote = @current_user_vote.root
      @old_rep_root = User.find(@old_root_vote.user_id)

      @current_user_vote.parent = @target_representative_vote
      @current_user_vote.save

      @new_root_vote = @current_user_vote.root
      @new_root_rep = User.find(@new_root_vote.user_id)

      response = firebase.push("delegates", {
        :incident => "redelegate",
        :old_rep_root_count => @old_root_vote.subtree.count,
        :old_rep_root_id => @old_rep_root.id,
        :new_rep_count => @target_representative_vote.subtree.count,
        :new_rep_id => @target_representative.id,
        :current_user_id => @current_user.id,
        :new_rep_root_count => @new_root_vote.subtree.count,
        :new_rep_root_id => @new_root_rep.id
        })

    # Delegate's current user's vote, which is currently not designated
    elsif @current_user_vote.root?
      puts "Delegate's current user's vote, which is currently not designated"
      @current_user_vote.parent = @target_representative_vote
      @current_user_vote.save

      @new_rep_vote = @current_user_vote.parent
      @new_rep = User.find(@new_rep_vote.user_id)

      @root_vote = @target_representative_vote.root
      @root = User.find(@root_vote.user_id)

      response = firebase.push("delegates", {
        :incident => "new delegate",
        :root_count => @root_vote.subtree.count,
        :root_user_id => @root.id,
        :new_rep_id => @new_rep.id,
        :current_user_id => @current_user.id
        })
    end

    @target_representative_vote.descendants.each do |vote|
      vote.value = @target_representative_vote.value
      vote.save
    end


    # response.success? # => true
    # response.code # => 200
    # response.body # => { 'name' => "-INOQPH-aV_psbk3ZXEX" }
    # response.raw_body # => '{"name":"-INOQPH-aV_psbk3ZXEX"}'

    render json: @target_representative_vote.descendants
  end




  def live
    base_uri = ENV['FIREBASE_URL']
    firebase = Firebase::Client.new(base_uri)
    firebase.delete("delegates")
    firebase.delete("votes")
    @current_issue = Issue.find(params[:id])
    # @current_issue.generate_leaderboard
    @participants = @current_issue.voters.order(id: :asc)




    if logged_in?
      @current_user = current_user
    else
      @current_user = User.first
    end

    @current_user_vote = @current_user.votes.find_by(issue_id: @current_issue.id)

    if !@current_user_vote.root?
      representative_vote =@current_user_vote.parent
      @representative_id = User.find(representative_vote.user_id).id
    end

  end

  # def graph
  #   @current_issue = Issue.find(params[:id])
  #   @yes_votes = @current_issue.votes.where({value: "yes"}).count
  #   @no_votes = @current_issue.votes.where({value: "no"}).count
  #   render json: {yes_votes: @yes_votes, no_votes: @no_votes}
  # end
end
