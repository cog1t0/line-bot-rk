Rails.application.routes.draw do
  resources :time_cards
  resources :users
  get '/sample' => 'sample#index'
  post '/callback' => 'webhook#callback'
end
