class Issue < ActiveRecord::Base
  has_many :votes
  has_many :voters, through: :votes, source: :user

  belongs_to :creator, class_name: 'User'
end
