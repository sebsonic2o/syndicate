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
    @delegate = User.find(params[:id])
    @delegate_vote = @delegate.votes.find_by(issue_id: params[:issue_id])

    @current_vote = current_user.votes.find_by(issue_id: params[:issue_id])

    @current_vote.parent = @delegate_vote
    @current_vote.save

    @delegate_vote.descendants.each do |vote|
      vote.value = @delegate_vote.value
      vote.save
    end

    render json: @delegate_vote
  end

  def live
    @current_issue = Issue.find(params[:id])
    @current_issue.generate_leaderboard
    @participants = @current_issue.voters
    # number of voters - AR
    # number of yes votes for this issue - AR
    # number of no votes for this issue - AR
    # number of abstains - ruby method
    # number of active votes - ruby method
    # percentage yes - ruby method
    # percentage no - ruby method

  end
end
