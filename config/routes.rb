Rails.application.routes.draw do
  #get 'sample/index'
  post '/callback' => 'webhook#callback'
end
