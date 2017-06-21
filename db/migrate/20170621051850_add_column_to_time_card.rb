class AddColumnToTimeCard < ActiveRecord::Migration[5.0]
  def change
    add_column :time_cards, :work_date, :date
  end
end
