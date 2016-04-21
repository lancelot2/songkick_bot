class ShopifyController < ApplicationController

  skip_before_action :verify_authenticity_token

  def req
   @products = JSON.parse(RestClient.get 'https://91b97aeb761861c20b777ede328d512e:ec169cbd05bcd7db7b03f5d6291a3f58@myshopifybot.myshopify.com/admin/products.json')
  end

end
