class Analyze < StructuredMessages

  def intent_determination(msg, context)
    keywords = [["categories", "category"], ["brands", "brand"]]
    tokenized_array = msg.split
    keywords.each {|array| context["intent"] = array.first if (tokenized_array & array).any? }
    context
  end

  def gender_determination(msg, context)
    keywords = [["men", "Men"],"women", "Women", "ladies", "lady"]]
    tokenized_array = msg.split
    keywords.each {|array| context["gender"] = array.first if (tokenized_array & array).any? }
    context
  end

  def brand_determination(msg, context)
    keywords = [["nike", "Nike"], ["adidas", "Adidas"], ["dedicated, Dedicated"]]
    tokenized_array = msg.split
    keywords.each {|array| context["brand"] = array.first if (tokenized_array & array).any? }
    context
  end

  def style_determination(msg, context)
    keywords = [["running", "Running"],["Sweatshirts", "sweatshirts"], ["Shirts", "shirts"]]
    tokenized_array = msg.split
    keywords.each {|array| context["style"] = array.first if (tokenized_array & array).any? }
    context
  end

  def answer(session, username, sender)
    if session.context["intent"].nil?
      sender.reply({text: "Hi, #{username} !"})
      cta_intent_message(sender)
    elsif session.context["intent"] == "categories"
      cta_categories_message(sender)
    elsif session.context["intent"] == "brands"
      cta_brands_message(sender)
    elsif session.context["intent"] == "categories" && session.context["style"].present?
      products = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products.json?product_type=#{context['style']}")
      generic_template_message(products, sender)
    elsif session.context["brands"] == "brands" && session.context["brand"].present?
      products = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products.json?&brand=#{context['brand']}")
      generic_template_message(products, sender)
    # elsif session.context["gender"] && session.context.count == 2
    #   sender.reply({text:"Which brand are you interested in ?"})
    # elsif session.context["style"] && session.context.count == 3
    #   sender.reply({text:"Which brand are you interested in ?"})
    # elsif session.context["brand"] && session.context.count == 3
    #   sender.reply({text:"Which style ?"})
    end
  end

  def update_context(msg, session)
    session.update(context: intent_determination(msg, session.context))
    session.update(context: gender_determination(msg, session.context))
    session.update(context: brand_determination(msg, session.context))
    session.update(context: style_determination(msg, session.context))
    session
  end
end
