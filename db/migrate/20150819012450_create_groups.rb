class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string     :name
    end

    create_table :group_users do |t|
      t.integer    :user_id         # The id of the member that belongs to this group
      t.integer    :group_id        # The group to which the member belongs
      t.string     :membership_type # The type of membership the member belongs with
    end

  end
end
