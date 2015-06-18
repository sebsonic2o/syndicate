class IssuesController < ApplicationController
  def index
    @issues = Issue.all
  end
  def show
    @issue = Issue.find(params[:id])
    p @issue
  end
  def live
    p "live"
    @issue = Issue.find(params[:id])
    # number of voters - AR
    # number of yes votes for this issue - AR
    # number of no votes for this issue - AR
    # number of abstains - ruby method
    # number of active votes - ruby method
    # percentage yes - ruby method
    # percentage no - ruby method



  end
end
