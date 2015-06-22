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
  end

  def delegate
    p params
    # IssueId = params[:issue_id]
    # RepresentativeId = params[:id]

    # Representative Details
    @representative = User.find(params[:id])
    # p @representative.get_votes(issue_id: params[:issue_id])
    @representative_vote = @representative.votes.find_by(issue_id: params[:issue_id])

    # Current User Details
    @current_user = current_user
    # p @current_user.get_votes(issue_id: params[:issue_id])
    @current_user_vote = current_user.votes.find_by(issue_id: params[:issue_id])
    p @current_user_vote.root?

    # Former Representative Details
    if @current_user_vote.root? == true
      p "No Parent - Set the current user to the former representative"
      @former_representative = User.find(@current_user.id)
      @former_representative_vote = @former_representative.votes.find_by(issue_id: params[:issue_id])
    else
      @former_representative = User.find(@current_user_vote.parent.user_id)
      @former_representative_vote = @former_representative.votes.find_by(issue_id: params[:issue_id])
    end


    # Delegates or redelegates current user's vote to a parent
    # if @current_user_vote.parent != @representative_vote
    #   @current_user_vote.parent = @representative_vote
    #   @current_user_vote.save
    # # Undelegates vote of current user
    # else
    #   @current_user_vote.parent = nil
    #   @current_user_vote.save
    # end

    # Update the Vote
    @current_user_vote.parent = @representative_vote
    @current_user_vote.save

    # Iterate over all descendants in the representatives tree and update their vote values to be the same as the representative
    @representative_vote.descendants.each do |vote|
      vote.value = @representative_vote.value
      vote.save
    end

    # Update Vote Counts --- must be done after Updating the vote
    if @former_representative.id == @current_user.id
      @representative_vote_count = @representative_vote.subtree.count
      @former_representative_vote_count = 0
    else
      @representative_vote_count = @representative_vote.subtree.count
      @former_representative_vote_count = @former_representative_vote.subtree.count
    end



    # Log Tests
    puts "*****************************************************************"
    puts "You clicked on user: #{@representative.id} - they are your representative"
    p @representative
    # .descendants does not include the representative
    @representative_vote.descendants
    # .subtree includes all descendants and the representive as well
    p @representative_vote.subtree
    puts "representative id: #{@representative.id}"
    puts "representative vote count: #{@representative_vote_count}"
    puts "current user id: #{@current_user.id}"

    puts "*****************************************************************"
    puts "Your former representative was user: #{@former_representative.id}"
    p @former_representative
    puts "former representative id: #{@former_representative.id}"
    puts "former representative vote count: #{@former_representative_vote_count}"


    # Firebase Ruby Connection Setup
    base_uri = ENV['FIREBASE_URL']
    firebase = Firebase::Client.new(base_uri)

    # need to push
    response = firebase.push("delegates", {
      :current_user_id => @current_user.id,
      :representative_id => @representative.id,
      :former_representative_id => @former_representative.id,
      :representative_vote_count => @representative_vote_count,
      :former_representative_vote_count => @former_representative_vote_count
    })

    response.success? # => true
    response.code # => 200
    response.body # => { 'name' => "-INOQPH-aV_psbk3ZXEX" }
    response.raw_body # => '{"name":"-INOQPH-aV_psbk3ZXEX"}'

    render json: @representative_vote.descendants
  end

  def live
    base_uri = ENV['FIREBASE_URL']
    firebase = Firebase::Client.new(base_uri)
    firebase.delete("delegates")
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
