class Analyze

  def initialize

  end

  def intent_determination(msg, context)
    keywords = [["categories", "category"], ["brands", "brand"],["pricerange", "price"], ["stock", "stocks"], ["info", "information"], ["no"], ["yes"]]
    tokenized_array = msg.split
    keywords.each {|array| context["intent"] = array.first if (tokenized_array & array).any? }
    context
  end

  def brand_determination(msg, context)
    keywords = [["nike", "Nike"], ["addidas", "adidas", "Adidas"], ["dedicated, Dedicated"]]
    tokenized_array = msg.split
    keywords.each {|array| context["brand"] = array.first if (tokenized_array & array).any? }
    context
  end

  def style_determination(msg, context)
    keywords = [["running", "Running"],["sweatshirts", "Sweatshirts"], ["shirts", "Shirts"]]
    tokenized_array = msg.split
    keywords.each {|array| context["style"] = array.first if (tokenized_array & array).any? }
    context
  end

  def price_range_determination(msg, context)
    keywords = [["less20", 0, 20],["20to50", 20, 50], ["more50", 50, 1000]]
    tokenized_array = msg.split
    keywords.each do |array|
      if (tokenized_array & array).any?
        context["pricerange"] = array.first
        context["pricemin"] = array[1]
        context["pricemax"] = array[2]
      end
    end
    context
  end

  def answer(session, username, sender)
    context = session.context
    if context["intent"].nil?
      sender.reply({text: "Hi, #{username} !"})
      sender.reply({text: "Welcome to the Hipster store. We are a small fashion store only selling hipster clothes."})
      sender.reply({text: "But our real purpose is not to sell you any apparel (just quite yet) but to illustrate the possibilities of chatbots developped by My A.I. Vendor."})
      sender.reply({text: "For now, you can navigate through our catalog of products the way you want. You can also try to type in some text directly. I might take a bit longer but I will do my best to always answer you."})
      sender.reply({text: "Let's get started !"})
      StructuredMessage.new.cta_intent_message(sender)
    elsif context["intent"] == "categories" && context["style"].present?
      products = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products.json?product_type=#{context['style']}")
      StructuredMessage.new.generic_template_message(products, sender)
    elsif context["intent"] == "brands" && context["brand"].present?
      products = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products.json?vendor=#{context['brand']}")
      StructuredMessage.new.generic_template_message(products, sender)
    elsif context["intent"] == "pricerange" && context["pricerange"].present?
      products = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products.json?")
      StructuredMessage.new.price_filtered_message(products, sender, context["pricemin"], context["pricemax"])
    elsif context["intent"] == "categories"
      StructuredMessage.new.cta_categories_message(sender)
    elsif context["intent"] == "brands"
      StructuredMessage.new.cta_brands_message(sender)
    elsif context["intent"] == "pricerange"
      StructuredMessage.new.cta_pricerange_message(sender)
    end
  end

  def analyse_yes(msg, session, sender)
    if msg.include? "no"
      sender.reply({text: "Well noted. I will send you an update as soon as we have it in stock"})
    else
      sender.reply({text: "Well noted. You can proceed check out in our store. "})
    end
  end

  def analyse_no(msg, session, sender)
    sender.reply({text: "Well noted. Do want to keep on shopping ? "})
  end

  def verify_stock(msg, session, sender)
    product_id = msg.gsub(": stock", "")
    product = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products/#{product_id}.json?")
    product_stock = product["product"]["variants"].first["inventory_quantity"]
    if product_stock > 0
      StructuredMessage.new.cta_stock_left_message(sender, product_stock)
    else
      StructuredMessage.new.cta_no_stock_left_message(sender)
    end
  end

  def retrieve_info(msg, session, sender)
    product_id = msg.gsub(": info", "")
    product = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products/#{product_id}.json?fields=image")
    more_info_message(product, sender)
  end

  def update_context(msg, session)
    session.update(context: intent_determination(msg, session.context))
    session.update(context: brand_determination(msg, session.context))
    session.update(context: style_determination(msg, session.context))
    session.update(context: price_range_determination(msg, session.context))
    session
  end
end

