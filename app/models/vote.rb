class Vote < ActiveRecord::Base
  has_ancestry
  belongs_to :issue
  belongs_to :user
end
