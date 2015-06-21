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

    base_uri = 'https://incandescent-heat-2238.firebaseio.com/'

    firebase = Firebase::Client.new(base_uri)

    response = firebase.push("delegates", { :delegate_count => @representative_vote.subtree.count, :delegate_vote_id => @representative.id})

    response.success? # => true
    response.code # => 200
    response.body # => { 'name' => "-INOQPH-aV_psbk3ZXEX" }
    response.raw_body # => '{"name":"-INOQPH-aV_psbk3ZXEX"}'

    p @representative_vote.descendants

    render json: @representative_vote.descendants
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
