Rails.application.routes.draw do
  get '/webhook', to: 'analyzer#webhook'
  post '/webhook', to: 'analyzer#webhook_post'
end
