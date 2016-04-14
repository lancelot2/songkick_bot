class AnalyzerController < ApplicationController
  def webhook
    render :json => params["hub.challenge"]

  end

  def webhook_post
    token = "CAAKs4sjMLtgBACbNSA3adhDT76dxu4A2iqNsZBcsfPgCMeVBZCbB7yGI5SiPU6PbfpFyi2W7zEclj8YXYxCG9VLcWZCBVT4XsBBEFJt6tAH8XYu1Y0W6BJsT2L6YNSvHnYV6pAgIaZB7HWrzchURHT0eSdyFB8OKR0wkkhjg0yatEx3XBIZAedcSRZAFXuSHIZD"
    url = "https://graph.facebook.com/v2.6/me/messages?"
    unless  params["entry"][0]["messaging"][0]["delivery"]
      messare_received = params["entry"][0]["messaging"][0]["message"]["text"]
      sender = params["entry"][0]["messaging"][0]["sender"]["id"]
      text = "Hello ! What can I do for you ?"

      request_params =  {
        recipient: {id: sender},
        message: {text: text},
        access_token: token
      }

      uri = URI.parse(url)

      response = Net::HTTP.new(uri.host, uri.port)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
      request.body = request_params.to_json

      http.request(request)
    end
  end
end
