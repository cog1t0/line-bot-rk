class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string  :name
      t.string  :line_user_id
      t.integer :work_style

      t.timestamps
    end
  end
end
