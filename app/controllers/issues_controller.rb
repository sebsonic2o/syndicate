class IssuesController < ApplicationController

  def index
    @issues = Issue.all
  end

  def show
    @current_issue = Issue.find(params[:id])
  end

  def vote
    @current_issue = Issue.find(params[:id])

    if @current_issue.closed?
      render json: {closed_message: "This issue is closed and cannot be voted on."}

    else
      @vote = current_user.votes.find_by(issue_id: params[:id])

      if @vote.root?
        @vote.update_attributes(value: params[:value])
        @vote.save

        @vote.descendants.each do |vote|
          vote.value = @vote.value
          vote.save
        end

        # @current_user_id = current_user.id
        # @current_user_vote_value = @vote.value

        firebase_vote(params[:id])
        render json: {}
      else
        puts "User has delegated their vote."
        render json: {delegated_vote_error: "You have already delegated your vote. "}
      end
    end
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
    response = firebase.delete("users")
  end

  def delegate
    @issue = Issue.find(params[:issue_id])

    if @issue.closed?
      render json: {closed_message: "This issue is closed and votes can no longer be delegated."}

    else 

      @target_representative = User.find(params[:id])
      @target_representative_vote = @target_representative.votes.find_by(issue_id: params[:issue_id])
      @current_user = current_user
      @current_user_vote = @current_user.votes.find_by(issue_id: params[:issue_id])

   # Firebase Ruby Connection Setup
      base_uri = ENV['FIREBASE_URL']
      firebase = Firebase::Client.new(base_uri)

      # Send error if user tries to delegate to someone in their subtree
      if @current_user_vote.descendants.include?(@target_representative_vote)
        puts "Hierachy error: cannot delegate to a user that is one of your descendants."

        render json: {hierachy_error: "You cannot delegate to a user who is directly or indirectly delegated to you."}

     # Undelegates vote of current user by clicking on yourself
      elsif @current_user == @target_representative
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
          :current_user_id => @current_user.id,
          :issue_id => @issue.id
          })

        render json: {}

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
          :current_user_id => @current_user.id,
          :issue_id => @issue.id
        })

        render json: {}

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
          :new_rep_root_id => @new_root_rep.id,
          :issue_id => @issue.id
        })

        render json: {}

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
          :current_user_id => @current_user.id,
          :issue_id => @issue.id
        })

        render json: {}
      end

      @target_representative_vote.descendants.each do |vote|
        vote.value = @target_representative_vote.value
        vote.save
      end

      firebase_vote(params[:issue_id])

    end

    # response.success? # => true
    # response.code # => 200
    # response.body # => { 'name' => "-INOQPH-aV_psbk3ZXEX" }
    # response.raw_body # => '{"name":"-INOQPH-aV_psbk3ZXEX"}'

    # render json: @target_representative_vote.descendants
  end

  def live
    @current_issue = Issue.find(params[:id])
    @participants = @current_issue.voters.order(id: :asc)
    @finish_time = @current_issue.finish_date

    if logged_in?
      @current_user = current_user
    else
      @current_user = User.first
    end

    if @current_issue.closed?
      puts "Issue is not open."

    else
      puts "Issue is open!"
      base_uri = ENV['FIREBASE_URL']
      firebase = Firebase::Client.new(base_uri)
      firebase.delete("delegates")
      firebase.delete("votes")
      firebase.delete("users")
      # @current_issue.generate_leaderboard


      @current_user_vote = @current_user.votes.find_by(issue_id: @current_issue.id)

      if !@current_user_vote.root?
        representative_vote =@current_user_vote.parent
        @representative_id = User.find(representative_vote.user_id).id
      end

    end
  end

  private

    def firebase_vote(id)
      issue = Issue.find(id)

      data = {
        issue_id: issue.id,
        participant_count: issue.participant_count,
        yes_votes: issue.yes_votes,
        no_votes: issue.no_votes,
        yes_percentage: issue.yes_percentage,
        no_percentage: issue.no_percentage,
        vote_count: issue.vote_count,
        abstain_count: issue.abstain_count,
        current_user_id: current_user.id,
        current_user_vote_value: current_user.votes.find_by(issue_id: id).value
      }

      firebase = Firebase::Client.new(ENV['FIREBASE_URL'])

      firebase.push("votes", data)
    end
end
