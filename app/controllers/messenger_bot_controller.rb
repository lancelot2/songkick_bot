class MessengerBotController < AnalyzeController

  def find_or_create_session(fbid, max_age: 5.minutes)
    Session.find_by(["facebook_id = ? AND last_exchange >= ?", fbid, max_age.ago]) ||
    Session.create(facebook_id: fbid, context: {})
  end

  def run_query(session)
    p session.context
    products = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products.json?collection_id=#{context['gender']}&brand=#{context['brand']}&product_type=#{context['style']}")
    p products
  end

  def analyze_request(msg, sender, session)
    update_context(session)
    p session.context
    run_query(session) if session.context.count == 3
    sender.reply({ text: msg })
  end

  def message(event, sender)
    msg = event["message"]["text"]
    sender_id = event["sender"]["id"]
    session = find_or_create_session(sender_id)
    session.update(last_exchange: Time.now)
    analyze_request(msg, sender, session)
  end

  def postback(event, sender)
    msg = event["postback"]["payload"]
    sender_id = event["sender"]["id"]
    session = find_or_create_session(sender)
    session.update(last_exchange: Time.now)
  end
end
