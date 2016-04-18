class TwilioController < ApplicationController
  include Webhookable

  after_filter :set_header

  skip_before_action :verify_authenticity_token

  def text
      account_sid = "AC27fc8675a5340aea2d9c1fdd6756160f"
      auth_token = "bb79881b9d4c0d2b31126f13259026be"
      @client = Twilio::REST::Client.new account_sid, auth_token
      @message = @client.messages.create(
        to: "+33632621718",
        from: "+33756797305",
        body: "Hello!"
      )
  end
end
