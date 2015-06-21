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

      base_uri = 'https://incandescent-heat-2238.firebaseio.com/'

      firebase = Firebase::Client.new(base_uri)

      response = firebase.push("votes", {
        participant_count: @current_issue.participant_count,
        yes_votes: @current_issue.yes_votes,
        no_votes: @current_issue.no_votes,
        yes_percentage: @current_issue.yes_percentage,
        no_percentage: @current_issue.no_percentage,
        vote_count: @current_issue.vote_count,
        abstain_count: @current_issue.abstain_count
      })
    else
      puts "User has delegated their vote."
    end

    render json: {}
    # render json: {
    #   participant_count: @current_issue.participant_count,
    #   yes_votes: @current_issue.yes_votes,
    #   no_votes: @current_issue.no_votes,
    #   yes_percentage: @current_issue.yes_percentage,
    #   no_percentage: @current_issue.no_percentage,
    #   vote_count: @current_issue.vote_count,
    #   abstain_count: @current_issue.abstain_count
    # }
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
    # @current_issue.generate_leaderboard
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

  # def graph
  #   @current_issue = Issue.find(params[:id])
  #   @yes_votes = @current_issue.votes.where({value: "yes"}).count
  #   @no_votes = @current_issue.votes.where({value: "no"}).count
  #   render json: {yes_votes: @yes_votes, no_votes: @no_votes}
  # end
end
