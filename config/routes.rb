Rails.application.routes.draw do
  root 'pages#home'
  mount Messenger::Bot::Space => "/webhook"

  get 'req' => 'analyzer#req'
  get 'shopify/req' => 'shopify#req'

end

