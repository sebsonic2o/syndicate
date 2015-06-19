class IssuesController < ApplicationController
  def index
    @issues = Issue.all
  end
  def show
    @current_issue = Issue.find(params[:id])
    p @current_issue
  end
  def live
    # @current_issue = Issue.find(params[:id])
    # @current_issue.generate_leaderboard

    # @participants = @current_issue.voters




    # number of voters - AR
    # number of yes votes for this issue - AR
    # number of no votes for this issue - AR
    # number of abstains - ruby method
    # number of active votes - ruby method
    # percentage yes - ruby method
    # percentage no - ruby method

  end
end
