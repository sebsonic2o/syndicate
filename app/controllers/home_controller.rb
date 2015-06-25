class HomeController < ApplicationController

  def index

    @hot_issues = Issue.where(:id => 1..6)

    render :layout => false
  end

  def about
    render :layout => false
  end
end
