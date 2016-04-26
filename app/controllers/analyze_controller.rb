class AnalyzeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:webhook, :webhook_post, :fb_request, :find_or_create_session]
  skip_before_action :verify_authenticity_token, only: [:webhook_post, :webhook, :fb_request, :find_or_create_session]

  def webhook
    render :json => params["hub.challenge"]
  end

  def send_request(request_params)
    uri = URI.parse(ENV["fb_url"])
    response = Net::HTTP.new(uri.host, uri.port)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    request.body = request_params.to_json
    http.request(request)
  end

  def fb_request(recipient_id, msg)
    request_params =  {
      recipient: {id: recipient_id},
      message: {text: msg},
      access_token: ENV["fb_token"]
    }
    send_request(request_params)
  end

  def find_or_create_session(fbid)
    @sessions = Session.all
    if @sessions.find_by facebook_id: fbid
      @session = @sessions.find_by facebook_id: fbid
      if ((Time.now - @session.last_exchange).fdiv(60)).to_i > 5
        @session = Session.build{facebook_id: fbid, context: {}}
      end
    else
      @session = Session.build{facebook_id: fbid, context: {}}
    end
    @session
  end

  def webhook_post
    access_token = ENV["wit_token"]
    @actions = {
      :say => -> (session_id, context, msg) {
        if context["stock_left"]
          @session = Session.find(session_id)
          @session.update (context: context)
          fb_request(@session.facebook_id, msg)
          @previous_session = @session
          @session = Session.build {facebook_id: @previous_session.facebook_id, context: {}}
        else
          @session = Session.find(session_id)
          @session.update(context: context)
        end
      },
      :merge => -> (session_id, context, entities, msg) {
        @session = Session.find(session_id)
        if entities["shoes_id"]
          context["stock_left"] = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products/#{entities['shoes_id'].first['value']}.json?fields=variants")["product"]["variants"].first["old_inventory_quantity"]
        end

        if entities["gender"]
          if entities["gender"].first["value"] == "men"
            context["gender"] = 263046279
          elsif entities["gender"].first["value"] == "wom"
            context["gender"] = 263046151
          end
        end

        if entities["brand"]
          context["brand"] = entities["brand"].first["value"]
        end

        if entities["style"]
          context["style"] = entities["style"].first["value"]
        end

        @session.update(context: context)
        fb_request(@session.facebook_id, msg)
        return context
      },
      :error => -> (session_id, context, error) {
        p 'Oops I don\'t know what to do.'
        msg = "I'm not sure to understand ..."
        fb_request(@session.facebook_id, msg)
      },
      :get_gender => -> (session_id, context) {
        @session = Session.find(session_id)
        @user = Oj.load(RestClient.get "https://graph.facebook.com/v2.6/#{@session.facebook_id}?fields=first_name,last_name,profile_pic&access_token=#{fb_token}")
          context["username"] = @user["first_name"]
          request_params =  {
          recipient: {id: @session.facebook_id},
          message: {
          "attachment":{
            "type":"template",
            "payload":{
              "template_type":"button",
               "text": "Is it for men or women ?",

                  "buttons":[
                      {
                      "type":"postback",
                      "title":"Women",
                      "payload":"wom"
                    },
                    {
                      "type":"postback",
                      "title":"Men",
                      "payload":"men"
                    }

                  ]
            }
          }
        },
          access_token: ENV["fb_token"]
        }
        send_request(request_params)
        return context
      },
      # :run_query => -> (session_id, context) {
      #   @session = Session.find(session_id)
      #   @products = Oj.load(RestClient.get "https://91b97aeb761861c20b777ede328d512e:ec169cbd05bcd7db7b03f5d6291a3f58@myshopifybot.myshopify.com/admin/products.json?collection_id=#{context['gender']}&brand=#{context['brand']}&product_type=#{context['style']}")
      #   request_params =  {
      #       recipient: {id: @session.facebook_id},
      #       message: {
      #       "attachment":{
      #         "type":"template",
      #         "payload":{
      #           "template_type":"generic",
      #           "elements":[
      #           ]
      #         }
      #       }
      #     },
      #       access_token: "CAAKs4sjMLtgBACbNSA3adhDT76dxu4A2iqNsZBcsfPgCMeVBZCbB7yGI5SiPU6PbfpFyi2W7zEclj8YXYxCG9VLcWZCBVT4XsBBEFJt6tAH8XYu1Y0W6BJsT2L6YNSvHnYV6pAgIaZB7HWrzchURHT0eSdyFB8OKR0wkkhjg0yatEx3XBIZAedcSRZAFXuSHIZD"
      #     }
      #   @products["products"].each do |h1|
      #     #fb_request(1006889982732663, h1["title"])
      #   request_params[:message][:attachment][:payload][:elements] << { "title": h1["title"],
      #       "image_url": h1["images"].first["src"],
      #       "subtitle":"",
      #       "buttons":[
      #         {
      #           "type":"web_url",
      #           "url":"https://petersapparel.parseapp.com/view_item?item_id=101",
      #           "title":"More info"
      #         },
      #         {
      #           "type":"postback",
      #           "payload": h1["id"],
      #           "title":"Check stock"
      #         },
      #         {
      #           "type":"postback",
      #           "title":"Similar items",
      #           "payload":"USER_DEFINED_PAYLOAD_FOR_ITEM101"
      #         }
      #       ]
      #     }


      #   end
      #   send_request(request_params)
      #   context = {}
      #   @session.context = context
      #   @session.save
      #   return context
      # }
    }

    client = Wit.new access_token, @actions
    params = Oj.load(params)
    if params["entry"][0]["messaging"][0]["delivery"].nil? && params["entry"][0]["messaging"][0]["postback"].nil?
      msg = params["entry"][0]["messaging"][0]["message"]["text"]
      sender = params["entry"][0]["messaging"][0]["sender"]["id"]
      @session = find_or_create_session(sender)
      @session.update(last_exchange: Time.now)
      client.run_actions @session.id, msg, @session.context
    elsif params["entry"][0]["messaging"][0]["postback"]
      postback_response = params["entry"][0]["messaging"][0]["postback"]["payload"]
      sender = params["entry"][0]["messaging"][0]["sender"]["id"]
      @session = find_or_create_session(sender)
      @session.update(last_exchange: Time.now)
      client.run_actions @session.id, postback_response, @session.context
    end
  end
end














