# class AnalyzerController < ApplicationController
#   skip_before_action :authenticate_user!, only: [:webhook, :webhook_post, :fb_request, :find_or_create_session]
#   skip_before_action :verify_authenticity_token, only: [:webhook_post, :webhook, :fb_request, :find_or_create_session]

#   def webhook
#     render :json => params["hub.challenge"]
#   end

#   def send_request(request_params)
#     RestClient.post ENV["fb_url"], request_params.to_json, :content_type => :json, :accept => :json
#   end

#   def fb_request(recipient_id, msg)
#     request_params = {
#       recipient: {id: recipient_id},
#       message: {text: msg},
#       access_token: ENV["fb_token"]
#     }
#     RestClient.post ENV["fb_url"], request_params.to_json, :content_type => :json, :accept => :json
#   end

#   def find_or_create_session(fbid)
#     if (@session = Session.find_by facebook_id: fbid)
#       p "FOUND"
#       @session
#     else
#       p "NEW SESSION"
#       @session = Session.create(facebook_id: fbid, context: {})
#     end
#   end

#   def webhook_post
#     @actions = {
#       :say => -> (session_id, context, msg) {
#         if context["stock_left"]
#           @session = Session.find(session_id)
#           @session.update(context: context)
#           fb_request(@session.facebook_id, msg)
#           @previous_session = @session
#           @session = Session.create(facebook_id: @previous_session.facebook_id, context: {})
#         else
#           @session = Session.find(session_id)
#           @session.update(context: context)
#           fb_request(@session.facebook_id, msg)
#         end
#       },
#       :merge => -> (session_id, context, entities, msg) {
#         @session = Session.find(session_id)
#         @user = Oj.load(RestClient.get "https://graph.facebook.com/v2.6/#{@session.facebook_id}?fields=first_name&access_token=#{ENV['fb_token']}")
#         context["username"] = @user["first_name"]
#         p entities
#         if entities["shoes_id"]
#           context["stock_left"] = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products/#{entities['shoes_id'].first['value']}.json?fields=variants")["product"]["variants"].first["old_inventory_quantity"]
#         end

#         if entities["gender"]
#           if entities["gender"].first["value"] == "men"
#             context["gender"] = 263046279
#           elsif entities["gender"].first["value"] == "wom"
#             context["gender"] = 263046151
#           end
#         end

#         if entities["brand"]
#           context["brand"] = entities["brand"].first["value"]
#         end

#         if entities["style"]
#           context["style"] = entities["style"].first["value"]
#         end
#         @session.update(context: context)

#         if ["browsing"]
#           @previous_session = @session
#           @session = Session.create(facebook_id: @previous_session.facebook_id, context: {})
#         end

#         p context
#         return context
#       },
#       :error => -> (session_id, context, error) {
#         p 'Oops I don\'t know what to do.'
#       },
#       :run_query => -> (session_id, context) {
#         @session = Session.find(session_id)
#         p context['gender']
#         p context['brand']
#         p context['style']
      #   if context['gender'].nil? || context['brand'].nil? || context['style'].nil?
      #     fb_request(@session.facebook_id, "I need more information")
      #   else
      #     @products = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products.json?collection_id=#{context['gender']}&brand=#{context['brand']}&product_type=#{context['style']}")
      #     request_params =  {
      #         recipient: {id: @session.facebook_id},
      #         message: {
      #         "attachment":{
      #           "type":"template",
      #           "payload":{
      #             "template_type":"generic",
      #             "elements":[
      #             ]
      #           }
      #         }
      #       },
      #         access_token: ENV["fb_token"]
      #       }
      #     @products["products"].each do |h1|
      #       request_params[:message][:attachment][:payload][:elements] << { "title": h1["title"],
      #           "image_url": h1["images"].first["src"],
      #           "subtitle":"",
      #           "buttons":[
      #             {
      #               "type":"web_url",
      #               "url":"#",
      #               "title":"More info"
      #             },
      #             {
      #               "type":"postback",
      #               "payload": h1["id"],
      #               "title":"Check stock"
      #             },
      #             {
      #               "type":"postback",
      #               "title":"Similar items",
      #               "payload":"similar"
      #             }
      #           ]
      #         }
      #     end
      #   send_request(request_params)
      # end
#         @previous_session = @session
#         @session = Session.create(facebook_id: @previous_session.facebook_id, context: {})
#         return context
#       }
#     }

#     client = Wit.new ENV["wit_token"], @actions
#     if params["entry"][0]["messaging"][0]["delivery"].nil? && params["entry"][0]["messaging"][0]["postback"].nil?
#       msg = params["entry"][0]["messaging"][0]["message"]["text"]
#       sender = params["entry"][0]["messaging"][0]["sender"]["id"]
#       @session = find_or_create_session(sender)
#       @session.update(last_exchange: Time.now)
#       client.run_actions @session.id, msg, @session.context
#     elsif params["entry"][0]["messaging"][0]["postback"]
#       postback_response = params["entry"][0]["messaging"][0]["postback"]["payload"]
#       sender = params["entry"][0]["messaging"][0]["sender"]["id"]
#       @session = find_or_create_session(sender)
#       @session.update(last_exchange: Time.now)
#       client.run_actions @session.id, postback_response, @session.context
#     end
#   end
# end
