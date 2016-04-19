class TwilioController < ApplicationController
  include Webhookable

  after_filter :set_header

  skip_before_action :verify_authenticity_token


   def send_text(msg)
      account_sid = "AC27fc8675a5340aea2d9c1fdd6756160f"
      auth_token = "bb79881b9d4c0d2b31126f13259026be"
      @client = Twilio::REST::Client.new account_sid, auth_token
      @message = @client.messages.create(
        to:   params["From"],
        from: "+33756798174",
        body: msg
      )
  end

  def reception
    access_token = "RNZ5ICWG3RUKRKT7ZNUSGCVIDB6CHGAT"
    recipientId = 0
    @actions = {}
    @actions = {
      :say => -> (session_id, context, msg) {
        send_text(msg)
      },
      :merge => -> (session_id, context, entities, msg) {
        return context
      },
      :error => -> (session_id, context, error) {
        p 'Oops I don\'t know what to do.'
      },
    }

    client = Wit.new access_token, @actions

    msg = params["Body"]
    sender = params["From"]
    session = rand(1..10000)
    client.run_actions session, msg, {}
  end
end
