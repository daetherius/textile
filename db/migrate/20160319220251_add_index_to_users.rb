class AddIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :barcode, unique: true
  end
end
