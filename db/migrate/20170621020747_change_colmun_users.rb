class ChangeColmunUsers < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :line_id, :line_user_id
  end
end
