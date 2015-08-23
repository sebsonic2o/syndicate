class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string     :name
      t.boolean    :public, default: true
    end

    create_table :group_users do |t|
      t.integer    :user_id
      t.integer    :group_id
      t.integer    :permission_id, :default => 1
    end

  end
end
