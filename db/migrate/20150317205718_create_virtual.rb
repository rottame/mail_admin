class CreateVirtual < ActiveRecord::Migration
  def change
    create_table :virtuals do |t|
      t.string  :email, index: :unique
      t.string  :destination, null: false
      t.boolean :enabled, default: true
    end
  end
end
