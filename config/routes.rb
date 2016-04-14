Rails.application.routes.draw do
  root 'pages#home'

  get '/webhook', to: 'analyzer#webhook'
  post '/webhook', to: 'analyzer#webhook_post'
end
