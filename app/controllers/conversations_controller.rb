class ConversationsController < ApplicationController
  before_action :set_user

  def new_conversation(sender)
    @conversation = Conversation.new
    @conversation.user = sender
    @conversation.save
  end

  def request
    @sender = User.find(params[:sender])
    token = "CAAKs4sjMLtgBACbNSA3adhDT76dxu4A2iqNsZBcsfPgCMeVBZCbB7yGI5SiPU6PbfpFyi2W7zEclj8YXYxCG9VLcWZCBVT4XsBBEFJt6tAH8XYu1Y0W6BJsT2L6YNSvHnYV6pAgIaZB7HWrzchURHT0eSdyFB8OKR0wkkhjg0yatEx3XBIZAedcSRZAFXuSHIZD"
    url = "https://graph.facebook.com/v2.6/me/messages?"
    text = "hello"
     request_params =  {
        recipient: {id: @sender.facebook_id},
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

  def answer
    text = "hell"
    request(text: "hello")
  end

  def new_message
    if @sender.conversations.nil?
      new_conversation
      answer
    else
      answer
    end
  end

  private

  def set_user
    @sender = User.find(params[:sender])
  end
end
