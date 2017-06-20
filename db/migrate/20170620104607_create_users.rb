class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :line_id
      t.string :style

      t.timestamps
    end
  end
end
