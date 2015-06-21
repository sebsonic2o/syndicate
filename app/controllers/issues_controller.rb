class IssuesController < ApplicationController
  def index
    @issues = Issue.all
  end

  def show
    @current_issue = Issue.find(params[:id])
    p @current_issue
  end

  def delegate
    @representative = User.find(params[:id])
    @representative_vote = @representative.votes.find_by(issue_id: params[:issue_id])
    @current_user_vote = current_user.votes.find_by(issue_id: params[:issue_id])

    # Delegates or redelegates current user's vote to a parent
    if @current_user_vote.parent != @representative_vote
      @current_user_vote.parent = @representative_vote
      @current_user_vote.save
    # Undelegates vote of current user
    else
      @current_user_vote.parent = nil
      @current_user_vote.save
    end

    @representative_vote.descendants.each do |vote|
      vote.value = @representative_vote.value
      vote.save
    end

    base_uri = 'https://incandescent-heat-2238.firebaseio.com/'

    firebase = Firebase::Client.new(base_uri)

    response = firebase.push("delegates", { :delegate_count => @representative_vote.subtree.count, :delegate_vote_id => @representative.id})

    response.success? # => true
    response.code # => 200
    response.body # => { 'name' => "-INOQPH-aV_psbk3ZXEX" }
    response.raw_body # => '{"name":"-INOQPH-aV_psbk3ZXEX"}'

    render json: @representative_vote.descendants
  end

  def live
    @current_issue = Issue.find(params[:id])
    @current_issue.generate_leaderboard
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

  def graph
    @current_issue = Issue.find(params[:id])
    @yes_votes = @current_issue.votes.where({value: "yes"}).count
    @no_votes = @current_issue.votes.where({value: "no"}).count
    render json: {yes_votes: @yes_votes, no_votes: @no_votes}
  end
end
