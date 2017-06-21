class ChangeColumnToUsersWorkStyle < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :work_style, :integer
  end
end
