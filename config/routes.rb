Rails.application.routes.draw do
  root 'pages#home'
  mount Messenger::Bot::Space => "/webhook"

  # get '/webhook', to: 'analyzer#webhook'
  # post '/webhook', to: 'analyzer#webhook_post'

  # get '/new_message', to: 'conversations#new_message'
  # get '/new_conversation', to: 'conversations#new'

  # get '/find_or_create_session', to:'analyzer#find_or_create_session'
  # get '/fb_request', to:'analyzer#fb_request'

  # get 'twilio/send_text' => 'twilio#send_text'
  # post 'twilio/reception' => 'twilio#reception'

  # get 'telegram/reception' => 'telegram#reception'
  get 'req' => 'analyzer#req'
  get 'shopify/req' => 'shopify#req'

  # get 'test' => 'analyzer#test'
end

