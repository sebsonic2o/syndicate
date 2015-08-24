class GroupUser < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :group
  belongs_to  :permission

  # before_create :assign_default_permission

  private

    def assign_default_permission
      self.permission_id = 1
    end

end
