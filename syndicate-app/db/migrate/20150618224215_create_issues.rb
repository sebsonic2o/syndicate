class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :title
      t.string :description
      t.datetime :start_date
      t.datetime :finish_date
      t.string :image_url

      t.integer :creator_id
      t.integer :group_id

      t.timestamps null: false
    end
  end
end
