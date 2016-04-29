class Analyze < StructuredMessages

  def intent_determination(msg, context)
    keywords = [["categories", "category"], ["brands", "brand"], ["stock", "stocks"], ["info", "information"], ["no"], ["yes"]]
    tokenized_array = msg.split
    keywords.each {|array| context["intent"] = array.first if (tokenized_array & array).any? }
    context
  end

  # def gender_determination(msg, context)
  #   keywords = [["men", "Men"],["women", "Women", "ladies", "lady"]]
  #   tokenized_array = msg.split
  #   keywords.each {|array| context["gender"] = array.first if (tokenized_array & array).any? }
  #   context
  # end

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

  def answer(session, username, sender)
    context = session.context
    if context["intent"].nil?
      sender.reply({text: "Hi, #{username} !"})
      cta_intent_message(sender)
    elsif context["intent"] == "categories" && context["style"].present?
      products = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products.json?product_type=#{context['style']}")
      generic_template_message(products, sender)
    elsif context["intent"] == "brands" && context["brand"].present?
      products = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products.json?vendor=#{context['brand']}")
      generic_template_message(products, sender)
    elsif context["intent"] == "categories"
      cta_categories_message(sender)
    elsif context["intent"] == "brands"
      cta_brands_message(sender)
    # elsif session.context["gender"] && session.context.count == 2
    #   sender.reply({text:"Which brand are you interested in ?"})
    # elsif session.context["style"] && session.context.count == 3
    #   sender.reply({text:"Which brand are you interested in ?"})
    # elsif session.context["brand"] && session.context.count == 3
    #   sender.reply({text:"Which style ?"})
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
      sender.reply({text: "We have #{product_stock} pairs left. Should I book one for you ?"})
    else
      sender.reply({text: "We don't have any pairs left. Should I notoify you when we'll receive one?"})
    end
  end

  def retrieve_info(msg, session, sender)
    product_id = msg.gsub(": info", "")
    product = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products/#{product_id}.json?")
    product_description = strip_tags(product["product"]["body_html"])
    sender.reply({text: product_description})
  end

  def update_context(msg, session)
    session.update(context: intent_determination(msg, session.context))
    #session.update(context: gender_determination(msg, session.context))
    session.update(context: brand_determination(msg, session.context))
    session.update(context: style_determination(msg, session.context))
    session
  end
end
