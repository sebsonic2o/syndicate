class Group < ActiveRecord::Base
  has_many :group_users
end
