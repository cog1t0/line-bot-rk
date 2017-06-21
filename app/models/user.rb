class User < ApplicationRecord
  has_many :time_cards
  enum work_style: {full_time:0, part_time:1}
end
