class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string  :type
      t.string :can_create_issue
      t.string :can
      t.timestamps null: false
    end
  end
end
