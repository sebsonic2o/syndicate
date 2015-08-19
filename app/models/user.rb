class User < ActiveRecord::Base

  has_many :group_users
  has_many :groups, through: :group_users, source: :group

  has_many :votes, dependent: :destroy
  has_many :voted_issues, through: :votes, source: :issue
  has_many :created_issues, foreign_key: :creator_id, class_name: 'Issue'

  validates :username, uniqueness: true

  attr_reader :total_vote_power

  def get_vote_power(issue_id)
    @delegate_vote = self.votes.find_by(issue_id: issue_id)
    if @delegate_vote.root?
      @total_vote_power = @delegate_vote.subtree.count
    else
      return 0
    end
  end

  def get_vote_status(issue_id)
    @vote = self.votes.find_by(issue_id: issue_id)
    @vote.value
  end

  def get_delegation_status(issue_id)
    @vote = self.votes.find_by(issue_id: issue_id)
    if !@vote.root?
      return "delegated"
    end
  end

  def get_votes(issue_id)
    @votes = self.votes.find_by(issue_id)
  end

end
