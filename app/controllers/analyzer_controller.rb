class AnalyzerController < ApplicationController
  skip_before_action :authenticate_user!, only: [:webhook, :webhook_post, :fb_request, :find_or_create_session]
  skip_before_action :verify_authenticity_token, only: [:webhook_post, :webhook, :fb_request, :find_or_create_session]

  def webhook
    render :json => params["hub.challenge"]
  end

  def req
    @products = RestClient.get 'https://91b97aeb761861c20b777ede328d512e:ec169cbd05bcd7db7b03f5d6291a3f58@myshopifybot.myshopify.com/admin/products.json?collection_id=263046279&vendor=nike&product_type=lifestyle'
    @collection = RestClient.get 'https://91b97aeb761861c20b777ede328d512e:ec169cbd05bcd7db7b03f5d6291a3f58@myshopifybot.myshopify.com/admin/custom_collections/263046279.json'
  end

  def fb_request(recipient_id, msg)
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
end

 def fb_structured_request(recipient_id, request_params)
  token = "CAAKs4sjMLtgBACbNSA3adhDT76dxu4A2iqNsZBcsfPgCMeVBZCbB7yGI5SiPU6PbfpFyi2W7zEclj8YXYxCG9VLcWZCBVT4XsBBEFJt6tAH8XYu1Y0W6BJsT2L6YNSvHnYV6pAgIaZB7HWrzchURHT0eSdyFB8OKR0wkkhjg0yatEx3XBIZAedcSRZAFXuSHIZD"
  url = "https://graph.facebook.com/v2.6/me/messages?"

  uri = URI.parse(url)

  response = Net::HTTP.new(uri.host, uri.port)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
  request.body = request_params.to_json

  http.request(request)
end

  def find_or_create_session(fbid)
    @sessions = Session.all
    if @sessions.find_by facebook_id: fbid
      @session = @sessions.find_by facebook_id: fbid
      if (Time.now - @session.last_exchange).fdiv(60) > 15
        @session = Session.new
        @session.facebook_id = fbid
        @session.context = {}
        @session.save
      end
      sessionId = @session.id
    else
      @session = Session.new
      @session.facebook_id = fbid
      @session.context = {}
      @session.save
    end
    @session
  end


  def webhook_post
    access_token = "KVGTTJ5B3PRINRMAZNPWN25E3YVT6QKB"


    recipientId = 0
    @actions = {}
    @actions = {
      :say => -> (session_id, context, msg) {
        @session = Session.find(session_id)
        @session.context = context
        @session.save
        fb_request(@session.facebook_id, msg)
      },
      :merge => -> (session_id, context, entities, msg) {
        @session = Session.find(session_id)
        p context
        if entities["gender"]
          if entities["gender"].first["value"] = "men"
            context["gender"] = 263046279
          else
            context["gender"] = 263046151
          end
        end

        if entities["brand"]
          context["brand"] = entities["brand"].first["value"].downcase
        end

        if entities["style"]
          context["style"] = entities["style"].first["value"].downcase
        end

        @session.context = context
        @session.save
        p context
        return context
      },
      :error => -> (session_id, context, error) {
        p 'Oops I don\'t know what to do.'
      },
      :run_query => -> (session_id, context) {
        @session = Session.find(session_id)
        p context
        @products = RestClient.get 'https://91b97aeb761861c20b777ede328d512e:ec169cbd05bcd7db7b03f5d6291a3f58@myshopifybot.myshopify.com/admin/products.json?collection_id=263046279&vendor=addidas&product_typ=running'
        p @products
        # JSON.parse(@products)["products"].each do |h1|
        #   p h1
        #   request_params =  {
        #       recipient: {id: 1006889982732663},
        #       message: {
        #       "attachment":{
        #         "type":"template",
        #         "payload":{
        #           "template_type":"generic",
        #           "elements":[
        #             {
        #                "title":  h1["title"] ,
        #                "image_url": h1["images"].first["src"],
        #                "subtitle": "Soft white cotton t-shirt is back in style",
        #               "buttons":[
        #                 {
        #                   "type":"web_url",
        #                   "url":"https://petersapparel.parseapp.com/view_item?item_id=100",
        #                   "title":"More info"
        #                 },
        #                 {
        #                   "type":"web_url",
        #                   "url":"https://petersapparel.parseapp.com/buy_item?item_id=100",
        #                   "title":"Check stock"
        #                 },
        #                 {
        #                   "type":"postback",
        #                   "title":"Similar products",
        #                   "payload":"USER_DEFINED_PAYLOAD_FOR_ITEM100"
        #                 }
        #               ]
        #             },
        #           ]
        #         }
        #       }
        #     },
        #       access_token: token
          }
          fb_structured_request(@session.facebook_id, request_params)
        end
        return context
      }
    }

    client = Wit.new access_token, @actions
    unless  params["entry"][0]["messaging"][0]["delivery"]
        msg = params["entry"][0]["messaging"][0]["message"]["text"]
        sender = params["entry"][0]["messaging"][0]["sender"]["id"]
        @session = find_or_create_session(sender)
        @session.last_exchange = Time.now
        @session.save
        client.run_actions @session.id, msg, @session.context
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
