class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :issue, index: true
      t.references :user, index: true
      t.string :ancestry, index: true
      t.string :value, default: 'abstain'

      t.timestamps null: false
    end
  end
end
