class AnalyzerController < ApplicationController
  skip_before_action :authenticate_user!, only: [:webhook, :webhook_post]
  skip_before_action :verify_authenticity_token, only: [:webhook_post, :webhook]

  def webhook
    render :json => params["hub.challenge"]
  end

  def create_user(facebook_id)
    @sender = User.new
    @sender.facebook_id = facebook_id
    @sender.save
    @sender
  end

  def webhook_post

    unless  params["entry"][0]["messaging"][0]["delivery"]
      if User.find_by facebook_id: params["entry"][0]["messaging"][0]["sender"]["id"]
        @sender = User.find_by facebook_id: params["entry"][0]["messaging"][0]["sender"]["id"]
        redirect_to new_message_path(sender: @sender)
      else
        create_user(params["entry"][0]["messaging"][0]["sender"]["id"])
        redirect_to new_message_path(sender: @sender)
      end

    #  message_received = params["entry"][0]["messaging"][0]["message"]["text"]
    end
  end
end
