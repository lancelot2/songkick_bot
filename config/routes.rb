Rails.application.routes.draw do
  root 'pages#home'

  get '/webhook', to: 'analyzer#webhook'
  post '/webhook', to: 'analyzer#webhook_post'

  get '/new_message', to: 'conversations#new_message'
  get '/new_conversation', to: 'conversations#new'
end
