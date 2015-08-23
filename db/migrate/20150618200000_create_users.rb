class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :image_url
      t.string :first_name, :string
      t.string :last_name, :string

      t.timestamps null: false
    end
  end
end
