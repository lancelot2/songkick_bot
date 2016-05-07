class MessengerBotController < ApplicationController

  skip_before_action :verify_authenticity_token

  def run_query(session, sender)
    context = session.context
    products = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products.json?collection_id=#{context['gender']}&brand=#{context['brand']}&product_type=#{context['style']}")
    generic_template_message(products, sender)
  end

  def analyze_request(msg, sender, session)
    @analyze = Analyze.new
    @analyze.update_context(msg, session)
    username = sender.get_profile[:body]["first_name"]
    p session.context
    if session.context["intent"] == "stock"
      @analyze.verify_stock(msg, session, sender)
    elsif session.context["intent"] == "info"
      @analyze.retrieve_info(msg, session, sender)
    # elsif session.context["intent"] == "yes"
    #   @analyze.analyse_yes(msg, session, sender)
    # elsif session.context["intent"] == "no"
    #   @analyze.analyse_no(msg, session, sender)
    else
      @analyze.answer(session, username, sender, msg)
    end
  end

  def find_address(lat, long)
     query = lat + ',' + long
     p result
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
    session = find_or_create_session(sender_id)
    session.update(last_exchange: Time.now)
    if event["postback"]["payload"]["coordinates"].present?
      latitude = event["postback"]["payload"]["coordinates"]["lat"]
      longitude = event["postback"]["payload"]["coordinates"]["long"]
      find_address(latitude, longitude)
    else
      analyze_request(msg, sender, session)
    end
  end

  private

  def find_or_create_session(fbid, max_age: 1.minutes)
    Session.find_by(["facebook_id = ? AND last_exchange >= ?", fbid, max_age.ago]) ||
    Session.create(facebook_id: fbid, context: {})
  end

end
