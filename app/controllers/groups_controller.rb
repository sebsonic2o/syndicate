class GroupsController < ApplicationController
  def index
    @groups = Group.all
    @issues = Issue.all
  end
end
