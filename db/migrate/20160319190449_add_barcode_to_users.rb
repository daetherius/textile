class AddBarcodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :barcode, :string
  end
end
