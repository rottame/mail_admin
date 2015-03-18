class CreateMailboxes < ActiveRecord::Migration
  def change
    create_table :mailboxes do |t|
      t.string :username, index: :unique, null: false
      t.string :password, null: false
      t.boolean :enabled, default: true

      t.timestamps null: false
    end
  end
end
