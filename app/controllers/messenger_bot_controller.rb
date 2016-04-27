class MessengerBotController < ActionController::Base

  def find_or_create_session(fbid, max_age: 5.minutes)
    Session.find_by(["facebook_id = ? AND last_exchange >= ?", fbid, max_age.ago]) ||
    Session.create(facebook_id: fbid, context: {})
  end

  def wit_request(msg, sender)
    @actions = {
      :say => -> (session_id, context, msg) {
          @session = Session.find(session_id)
          @session.update(context: context)
          sender.reply({ text: msg })
      },
      :merge => -> (session_id, context, entities, msg) {
        @session = Session.find(session_id)
        p entities
        context["username"] = sender.get_profile[:body]["first_name"]
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
        p context
        return context
      },
      :error => -> (session_id, context, error) {
        p 'Oops I don\'t know what to do.'
      },
      :run_query => -> (session_id, context) {
        @session = Session.find(session_id)
        p context['gender']
        p context['brand']
        p context['style']
        products = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products.json?collection_id=#{context['gender']}&brand=#{context['brand']}&product_type=#{context['style']}")
        products["products"].each do |h1|
          sender.reply({ text: h1["title"] })
        end
        return context
      }
    }

  end

  def message(event, sender)
    msg = event["message"]["text"]
    sender_id = event["sender"]["id"]
    session = find_or_create_session(sender_id)
    session.update(last_exchange: Time.now)
    wit_request(msg, sender)
    client = Wit.new ENV["wit_token"], @actions
    client.run_actions session.id, msg, session.context
  end

  def postback(event, sender)
    msg = event["postback"]["payload"]
    sender_id = event["sender"]["id"]
    session = find_or_create_session(sender)
    session.update(last_exchange: Time.now)
    wit_request(msg, sender)
    client = Wit.new ENV["wit_token"], @actions
    client.run_actions session.id, payload, session.context
  end
end
