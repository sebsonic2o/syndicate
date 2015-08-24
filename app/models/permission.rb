class Permission < ActiveRecord::Base
  has_many :group_users
end
