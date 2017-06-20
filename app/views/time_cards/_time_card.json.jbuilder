json.extract! time_card, :id, :user_id, :arrival_time, :leave_time, :created_at, :updated_at
json.url time_card_url(time_card, format: :json)
