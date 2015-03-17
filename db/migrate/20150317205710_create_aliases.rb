class CreateAliases < ActiveRecord::Migration
  def change
    create_table :aliases do |t|
      t.string  :origin, index: true, null: false
      t.text    :destinations, null: false
      t.boolean :to_self, default: true
      t.boolean :enabled, default: true

      t.text    :to, null: false

      t.index   [:origin, :enabled], unique: true
    end
  end
end
