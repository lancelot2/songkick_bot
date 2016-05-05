class Analyze

  def initialize

  end

  def intent_determination(msg, context)
    previous_context = context
    p "PREVIOUS CONTEXT"
    p previous_context
    keywords = [["categories", "category"],["yessizes"], ["nosizes"], ["brands", "brand"],["pricerange", "price"], ["sizes", "size"], ["stock", "stocks"], ["info", "information"], ["no", "No"], ["yes", "Yes"]]
    tokenized_array = msg.split
    keywords.each {|array| context["intent"] = array.first if (tokenized_array & array).any? }
    if context["intent"] == "info"
      context["product_id"] = msg.gsub(": info", "")
    elsif context["intent"] == "sizes" && previous_context["intent"] == "sizes" && context.key? :size
      p "TRUE"
      context["intent"] = "booksize"
    elsif context["intent"] == ("sizes") && (msg.include? ": sizes")
      context["product_id"] = msg.gsub(": sizes", "")
    end
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

  def size_determination(msg, context)
    keywords = [["allsizes", "all", "All"],["Medium", "m", "M", "medium"], ["Large", "l", "large", "L"],["Small", "s", "S", "small"],["Extra-Small", "xs", "extra-small", "XS"]]
    tokenized_array = msg.split
    keywords.each {|array| context["size"] = array.first if (tokenized_array & array).any? }
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
    previous_context = context
    if context["intent"].nil?
      sender.reply({text: "Hi, #{username} !"})
      sleep(1)
      sender.reply({text: "Welcome to the Hipster store. We are a small fashion store only selling hipster clothes."})
      sleep(1)
      sender.reply({text: "But our real purpose is not to sell you any apparel (just quite yet) but to illustrate the possibilities of chatbots developped by My A.I. Vendor."})
      sleep(1)
      sender.reply({text: "For now, you can navigate through our catalog of products the way you want. You can also try to type in some text directly. I might take a bit longer but I will do my best to always answer you."})
      sleep(1)
      sender.reply({text: "Let's get started !"})
      StructuredMessage.new.cta_intent_message(sender)
    elsif context["intent"] == "sizes" && context["size"].present?
      product = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products/#{context['product_id']}.json?")
      ans = " "
      if context["size"] == "allsizes"
        product["product"]["variants"].each do |variant|
          ans = ans + variant["title"].to_s + ": " +  variant["inventory_quantity"].to_s + "left \n"
        end
        ans = ans + "Do you want me to book a size in particular ?"
        sender.reply({text: ans})
      else
        product["product"]["variants"].each do |variant|
          if (variant["title"] == context["size"]) && (variant["inventory_quantity"] > 0)
            ans = "We have some left ! Do you want me to book it for you ?"
          elsif variant["title"] == context["size"]
            ans = "I am sorry, it seems that this product is quite popular and we no longer have stock. Do you want me to notify you when it will be back on stock ?"
          end
        end
        sender.reply({text: ans})
      end
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
    elsif context["intent"] == "sizes"
      StructuredMessage.new.cta_sizes_choice_message(sender)
    elsif context["intent"] == "nosizes"
      StructuredMessage.new.cta_sizes_choice_message(sender)
    elsif context["intent"] == "booksize"
      sender.reply({text:" Done. How do you want to proceed ?"})
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
    product = Oj.load(RestClient.get "https://#{ENV['shopify_token']}@myshopifybot.myshopify.com/admin/products/#{product_id}.json?fields=images")
    StructuredMessage.new.more_info_message(product, sender)
  end

  def update_context(msg, session)
    session.update(context: size_determination(msg, session.context))
    session.update(context: intent_determination(msg, session.context))
    session.update(context: brand_determination(msg, session.context))
    session.update(context: style_determination(msg, session.context))
    session.update(context: price_range_determination(msg, session.context))
    session
  end
end

