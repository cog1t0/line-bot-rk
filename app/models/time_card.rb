class TimeCard < ApplicationRecord
  belongs_to :user
  def self.to_csv
    CSV.generate do |csv|
      csv << ["name","day","start","end"]
      all.each do |tc|
        csv << [tc.user.name, tc.work_date, tc.arrival_time, tc.leave_time]
      end
    end
  end
end
