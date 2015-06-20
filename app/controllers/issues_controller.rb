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
    @vote = current_user.votes.find_by(issue_id: params[:id])

    if @vote.root?
      @vote.update_attributes(value: params[:value])
      @vote.save
    else
      puts "User has delegated their vote."
    end

    @vote.descendants.each do |vote|
      vote.value = @vote.value
      vote.save
    end

    render json: @vote
  end

  def delegate
    @representative = User.find(params[:id])
    @representative_vote = @representative.votes.find_by(issue_id: params[:issue_id])

    @current_user_vote = current_user.votes.find_by(issue_id: params[:issue_id])

    @current_user_vote.parent = @representative_vote
    @current_user_vote.save

    p @representative_vote.descendants

    @representative_vote.descendants.each do |vote|
      vote.value = @representative_vote.value
      vote.save
    end

    render json: @representative.get_vote_power(params[:issue_id])

  end

  def live
    @current_issue = Issue.find(params[:id])
    @current_issue.generate_leaderboard
    @participants = @current_issue.voters.order(id: :asc)
  end

  def graph
    @current_issue = Issue.find(params[:id])
    @yes_votes = @current_issue.votes.where({value: "yes"}).count
    @no_votes = @current_issue.votes.where({value: "no"}).count
    render json: {yes_votes: @yes_votes, no_votes: @no_votes}
  end
end
