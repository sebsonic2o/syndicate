class Issue < ActiveRecord::Base

  has_many :votes
  has_many :voters, through: :votes, source: :user

  belongs_to :creator, class_name: 'User'

  attr_reader :string, :participant_count, :vote_count, :yes_votes, :yes_percentage, :no_votes, :no_percentage, :abstain_count

  def get_participants_count
    @participant_count = self.votes.count
  end

  def get_vote_count
    @vote_count = self.votes.count
  end

  def get_yes_votes
    @yes_votes = self.votes.where(params[:value] == "yes")
  end

  def get_yes_percentage
    @yes_percentage = @yes_votes / @vote_count
  end

  def get_no_votes
    @no_votes = self.votes.where(params[:value] == "no")
  end

  def get_no_percentage
    @no_percentage = @no_votes / @vote_count
  end

  def get_abstain_count
    @abstain_count = @participants - (@no_votes + @yes_votes)
  end

  def generate_leaderboard
    # get_participants
    # get_vote_count
    # get_yes_votes
    # get_yes_percentage
    # get_no_votes
    # get_no_percentage
    # get_abstain_count
    hello
  end

  def hello
    @string = "hello"
  end
end
