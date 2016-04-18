Rails.application.routes.draw do
  root 'pages#home'

  get '/webhook', to: 'analyzer#webhook'
  post '/webhook', to: 'analyzer#webhook_post'

  get '/new_message', to: 'conversations#new_message'
  get '/new_conversation', to: 'conversations#new'

  get '/find_or_create_session', to:'analyzer#find_or_create_session'
  get '/fb_request', to:'analyzer#fb_request'

  post 'twilio/text' => 'twilio#text'

end

