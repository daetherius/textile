class AddContextToChecks < ActiveRecord::Migration
  def change
    add_column :checks, :context, :integer
  end
end
