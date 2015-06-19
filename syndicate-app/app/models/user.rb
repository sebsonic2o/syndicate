class User < ActiveRecord::Base
  has_many :votes
  has_many :voted_issues, through: :votes, source: :issue

  has_many :created_issues, foreign_key: :creator_id, class_name: 'Issue'

end
