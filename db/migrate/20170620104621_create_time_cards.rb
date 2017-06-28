class CreateTimeCards < ActiveRecord::Migration[5.0]
  def change
    create_table :time_cards do |t|
      t.integer  :user_id
      t.date     :work_date
      t.datetime :arrival_time
      t.datetime :leave_time

      t.timestamps
    end
  end
end
