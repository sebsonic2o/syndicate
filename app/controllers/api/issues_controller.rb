class Api::IssuesController < ApplicationController

  def index
    firebase_client.delete("votes")
    @issues = Issue.all
  end

  def show
    @issue = Issue.find(params[:id])
  end

  def new 
    # @issue = Issue.new()
  end

  def create
    @issue = Issue.new(title: params[:title], description: params[:description])
    @issue.start_date = Time.now,
    @issue.finish_date = Faker::Time.forward(60, :all),
    @issue.save
    @issue.voters = User.all
    render 'show'
  end

  def update
    @issue = Issue.find(params[:id])
    @issue.update_attributes(params.require(:issue).permit(:title,:description))
    head :no_content
  end

  def destroy
    @issue = Issue.find(params[:id])
    @issue.destroy
    head :no_content
  end


  def live
    @issue = Issue.find(params[:issue_id])
    @participants = @issue.voters.order(id: :asc)
    @finish_time = @issue.finish_date.utc

    # clear firebase
    firebase_client.delete("delegates")
    firebase_client.delete("votes")
    firebase_client.delete("users")

    if @issue.closed?
      puts "Issue is closed!"
    else
      puts "Issue is open!"

      if logged_in?
        @current_user_vote = current_user.votes.find_by(issue_id: @issue.id)

        if !@current_user_vote.root?
          representative_vote = @current_user_vote.parent
          @representative_id = User.find(representative_vote.user_id).id
        end
      end

    end
  end

  def vote
    @current_issue = Issue.find(params[:id])

    if @current_issue.closed?
      render json: {closed_message: "This issue is closed and cannot be voted on."}

    else

      if !logged_in?
        render json: {log_in_error: "You must be logged in to vote."}
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

          firebase_vote(params[:id], true)
          render json: {}
        else
          render json: {delegated_vote_error: "You have already delegated your vote. If you wish to vote directly, first undelegate your vote. "}
        end

      end
    end
  end

  def clear
    @current_issue = Issue.find(params[:id])
    @all_votes = @current_issue.votes
    @all_votes.each do |vote|
      vote.ancestry = nil
      vote.value = "abstain"
      p vote.save
    end

    # clear firebase
    firebase_client.delete("delegates")
    firebase_client.delete("votes")
    firebase_client.delete("users")
  end

  def set_time
    current_issue = Issue.find(params[:id])
    current_issue.finish_date = Time.now + params[:minutes].to_i.minutes
    current_issue.save
    redirect_to action: "live", id: params[:id]
  end

  def delegate
    @issue = Issue.find(params[:issue_id])

    if @issue.closed?
      render json: {closed_message: "This issue is closed and votes can no longer be delegated."}
    else

      if !logged_in?
        render json: {log_in_error: "You must be logged in to delegate your vote."}
      else

        @target_representative = User.find(params[:id])
        @target_representative_vote = @target_representative.votes.find_by(issue_id: params[:issue_id])
        @current_user_vote = current_user.votes.find_by(issue_id: params[:issue_id])

        # Send error if user tries to delegate to someone in their subtree
        if @current_user_vote.descendants.include?(@target_representative_vote)

          render json: {hierachy_error: "You cannot delegate to a user who is directly or indirectly delegated to you."}

        # Undelegates vote of current user by clicking on yourself
        elsif current_user == @target_representative
          puts "Undelegates vote of current user BY CLICKING ON SELF"

          @old_root_vote = @current_user_vote.root
          @old_rep_root = User.find(@old_root_vote.user_id)

          @old_rep_id = @current_user_vote.parent.user_id

          @current_user_vote.parent = nil
          @current_user_vote.save

          firebase_client.push("delegates", {
            :incident => "undelegate",
            :old_rep_root_count => @old_root_vote.subtree.count,
            :old_rep_root_id => @old_rep_root.id,
            :old_rep_id => @old_rep_id,
            :current_user_count => @current_user_vote.subtree.count,
            :current_user_id => current_user.id,
            :issue_id => @issue.id
          })

          move = true
          render json: {}

        # Undelegates vote of current user by clicking on the rep
        elsif @current_user_vote.parent == @target_representative_vote
          puts "Undelegates vote of current user"

          @old_root_vote = @current_user_vote.root
          @old_rep_root = User.find(@old_root_vote.user_id)

          @old_rep_id = @current_user_vote.parent.user_id

          @current_user_vote.parent = nil
          @current_user_vote.save

          firebase_client.push("delegates", {
            :incident => "undelegate",
            :old_rep_root_count => @old_root_vote.subtree.count,
            :old_rep_root_id => @old_rep_root.id,
            :old_rep_id => @old_rep_id,
            :current_user_count => @current_user_vote.subtree.count,
            :current_user_id => current_user.id,
            :issue_id => @issue.id
          })

          move = true
          render json: {}

        # Redelegates current user's vote to a new parent
        elsif !@current_user_vote.root? && @current_user_vote.parent != @target_representative_vote
          puts "Redelegates current user's vote to a new parent"

          @old_root_vote = @current_user_vote.root
          @old_rep_root = User.find(@old_root_vote.user_id)

          @old_rep_id = @current_user_vote.parent.user_id

          @current_user_vote.parent = @target_representative_vote
          @current_user_vote.save

          @new_root_vote = @current_user_vote.root
          @new_root_rep = User.find(@new_root_vote.user_id)

          firebase_client.push("delegates", {
            :incident => "redelegate",
            :old_rep_root_count => @old_root_vote.subtree.count,
            :old_rep_root_id => @old_rep_root.id,
            :old_rep_id => @old_rep_id,
            :new_rep_count => @target_representative_vote.subtree.count,
            :new_rep_id => @target_representative.id,
            :current_user_id => current_user.id,
            :new_rep_root_count => @new_root_vote.subtree.count,
            :new_rep_root_id => @new_root_rep.id,
            :issue_id => @issue.id
          })

          move = false
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

          firebase_client.push("delegates", {
            :incident => "new delegate",
            :root_count => @root_vote.subtree.count,
            :root_user_id => @root.id,
            :new_rep_id => @new_rep.id,
            :current_user_id => current_user.id,
            :issue_id => @issue.id
          })

          move = false
          render json: {}
        end

        @target_representative_vote.descendants.each do |vote|
          vote.value = @target_representative_vote.value
          vote.save
        end

        firebase_vote(params[:issue_id], move)
      end
    end

  end

  private

    def firebase_vote(id, move)
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
        current_user_vote_value: current_user.votes.find_by(issue_id: id).value,
        move_to_vote_zone: move
      }

      firebase_client.push("votes", data)
    end
end
