class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string  :role
      t.string  :can_create_issue
      t.timestamps null: false
    end
  end
end
