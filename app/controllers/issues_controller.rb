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
    @current_issue = Issue.find(params[:id])
    @vote = current_user.votes.find_by(issue_id: params[:id])

    if @vote.root?
      @vote.update_attributes(value: params[:value])
      @vote.save

      @vote.descendants.each do |vote|
        vote.value = @vote.value
        vote.save
      end
    else
      puts "User has delegated their vote."
    end

    render json: {
      vote: @vote,
      yes_votes: @current_issue.get_yes_votes,
      yes_percentage: @current_issue.get_yes_percentage,
      no_votes: @current_issue.get_no_votes,
      no_percentage: @current_issue.get_no_percentage
    }
  end

  def delegate
    @representative = User.find(params[:id])
    @representative_vote = @representative.votes.find_by(issue_id: params[:issue_id])
    @current_user_vote = current_user.votes.find_by(issue_id: params[:issue_id])

    @current_user_vote.parent = @representative_vote
    @current_user_vote.save

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
  end

  # def graph
  #   @current_issue = Issue.find(params[:id])
  #   @yes_votes = @current_issue.votes.where({value: "yes"}).count
  #   @no_votes = @current_issue.votes.where({value: "no"}).count
  #   render json: {yes_votes: @yes_votes, no_votes: @no_votes}
  # end
end
