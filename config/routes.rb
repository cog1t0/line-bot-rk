Rails.application.routes.draw do
  get '/sample' => 'sample#index'
  post '/callback' => 'webhook#callback'
end
