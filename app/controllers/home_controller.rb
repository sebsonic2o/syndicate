class HomeController < ApplicationController

  def index
    @issues = Issue.where(:id => 1..6)
  end

  def about
    render :layout => false
  end
end
