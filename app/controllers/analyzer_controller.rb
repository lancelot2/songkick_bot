class AnalyzerController < ApplicationController
  skip_before_action :authenticate_user!, only: [:webhook, :webhook_post, :fb_request, :find_or_create_session]
  skip_before_action :verify_authenticity_token, only: [:webhook_post, :webhook, :fb_request, :find_or_create_session]

  def webhook
    render :json => params["hub.challenge"]
  end

  # def create_user(facebook_id)
  #   @sender = User.new
  #   @sender.facebook_id = facebook_id
  #   @sender.save
  #   @sender
  # end


  def fb_request(recipient_id, msg, cb)
  token = "CAAKs4sjMLtgBACbNSA3adhDT76dxu4A2iqNsZBcsfPgCMeVBZCbB7yGI5SiPU6PbfpFyi2W7zEclj8YXYxCG9VLcWZCBVT4XsBBEFJt6tAH8XYu1Y0W6BJsT2L6YNSvHnYV6pAgIaZB7HWrzchURHT0eSdyFB8OKR0wkkhjg0yatEx3XBIZAedcSRZAFXuSHIZD"
  url = "https://graph.facebook.com/v2.6/me/messages?"

  request_params =  {
    recipient: {id: recipient_id},
    message: {text: msg},
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

  response = http.request(request)
end

  def find_or_create_session(fbid)
    @sessions = Session.all
    if @sessions.find_by facebook_id: fbid
      @session = @sessions.find_by facebook_id: fbid
      sessionId = @session.session_id
    else
      @session = Session.new
      @session.id = Date.today.to_time.to_i.to_s
      @session.facebook_id = fbid
      @session.context = {}
      @session.save
    end
    @session
  end


  def webhook_post
    recipientId = 0

    actions = {
      :say => -> (session_id, context, msg, cb) {
        @session = Session.find_by session_id: session_id
        recipientId = @session.facebook_id
        if recipientId
          fbMessage(recipientId, msg, cb)
        else
          puts "no session id"
        end
      },
      :merge => -> (session_id, context, entities, msg) {
       return context
      },
      :error => -> (session_id, context) {
        p 'Oops I don\'t know what to do.'
      },
    }

    unless  params["entry"][0]["messaging"][0]["delivery"]
      msg = params["entry"][0]["messaging"][0]["message"]["text"]
      sender = params["entry"][0]["messaging"][0]["sender"]["id"]
      @session = find_or_create_session(sender)
      client.run_actions @session.session_id, msg, @session.context
    end
  end
end


  # if User.find_by facebook_id: params["entry"][0]["messaging"][0]["sender"]["id"]
      #   @sender = User.find_by facebook_id: params["entry"][0]["messaging"][0]["sender"]["id"]
      #   redirect_to new_message_path(sender: @sender)
      # else
      #   create_user(params["entry"][0]["messaging"][0]["sender"]["id"])
      #   redirect_to new_message_path(sender: @sender)
      # end

    #  message_received = params["entry"][0]["messaging"][0]["message"]["text"]
