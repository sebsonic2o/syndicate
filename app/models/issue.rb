class Issue < ActiveRecord::Base

  has_many :votes
  has_many :voters, through: :votes, source: :user

  belongs_to :groups
  belongs_to :creator, class_name: 'User'

  # attr_reader :string, :participant_count, :vote_count, :yes_votes, :yes_percentage, :no_votes, :no_percentage, :abstain_count

  def participant_count
    votes.count
    # @participant_count ||= votes.count

    # puts "PARTICIPANTS  COUNT " * 5
    # puts @participant_count
  end

  def yes_votes
    votes.where({value: "yes"}).count
    # @yes_votes ||= votes.where({value: "yes"}).count

    # puts "YES VOTES " * 5
    # p @yes_votes
  end

  def no_votes
    votes.where({value: "no"}).count
    # @no_votes ||= votes.where({value: "no"}).count

    # puts "NO VOTES " * 5
    # p @no_votes
  end

  def vote_count
    yes_votes + no_votes
    # @vote_count ||= yes_votes + no_votes

    # puts "VOTE COUNT" * 5
    # puts @vote_count
  end

  def abstain_count
    participant_count - vote_count
    # @abstain_count ||= participant_count - vote_count

    # puts "ABSTAIN COUNT" * 5
    # puts @abstain_count
  end

  def yes_percentage
    vote_count == 0 ? 0 : (yes_votes.to_f / vote_count * 100).round(2)
    # @yes_percentage || = (vote_count == 0 ? 0 : (yes_votes.to_f / vote_count * 100).round(2))

    # @yes_percentage = 0 if @yes_percentage.nan?
    # puts "YES PERCENT " * 5
    # @yes_percentage.round(2)
  end


  def no_percentage
    vote_count == 0 ? 0 : (no_votes.to_f / vote_count * 100).round(2)
    # @no_percentage ||= (vote_count == 0 ? 0 : (no_votes.to_f / vote_count * 100).round(2))

    # @no_percentage = 0 if @no_percentage.nan?
    # puts "NO PERCENT " * 5
    # p @no_percentage.round(2)
  end

  def closed?
    self.finish_date < Time.now
  end

  def status
    if self.closed?
      return "closed"
    else
      return "open"
    end
  end

  def time_remaining
    raw = self.finish_date.utc - Time.now
    minutes = raw / 60
    hours = (minutes / 60).to_i
    minutes_after_hours = (minutes % 60).to_i

    if raw < 0
      return "Voting finished"
    else
      return "Time remaining: #{hours}h #{minutes_after_hours}m"
    end
  end
  # def generate_leaderboard
  #   get_participants_count
  #   get_yes_votes
  #   get_no_votes
  #   get_vote_count
  #   get_abstain_count
  #   get_yes_percentage
  #   get_no_percentage
  # end

  # def hello
  #   @string = "hello"
  # end
end
