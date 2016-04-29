class Analyze < StructuredMessages

  def intent_determination(msg, context)
    categories_keywords = ["categories", "category"]
    brands_keywords = ["brand", "brands"]
    tokenized_array = msg.split
    if (tokenized_array & categories_keywords).any?
      context["intent"] = "categories"
    elsif (tokenized_array & brands_keywords).any?
      context["intent"] = "brands"
    end
    context
  end

  def gender_determination(msg, context)
    men_keywords = ["men", "Men"]
    women_keywords = ["women", "Women", "ladies", "lady"]
    tokenized_array = msg.split
    if (tokenized_array & men_keywords).any?
      context["gender"] = 263046279
    elsif (tokenized_array & women_keywords).any?
       context["gender"] = 263046151
    end
    context
  end

  def brand_determination(msg, context)
    nike_keywords = ["nike", "Nike"]
    adidas_keywords = ["adidas", "Adidas"]
    tokenized_array = msg.split
    if (tokenized_array & nike_keywords).any?
      context["brand"] = "nike"
    elsif (tokenized_array & adidas_keywords).any?
       context["brand"] = "adidas"
    end
    context
  end

  def style_determination(msg, context)
    running_keywords = ["running", "Running"]
    lifestyle_keywords = ["lifestyle", "Lifestyle"]
    sweatshirts_keywords = ["Sweatshirts", "sweatshirts"]
    shirts_keywords = ["Shirts", "shirts"]
    tshirts_keywords = ["t-shirts", "T-Shirts"]

    tokenized_array = msg.split
    if (tokenized_array & running_keywords).any?
      context["style"] = "running"
    elsif (tokenized_array & lifestyle_keywords).any?
      context["style"] = "lifestyle"
    elsif (tokenized_array & shirts_keywords).any?
      context["style"] = "shirts"
    elsif (tokenized_array & sweatshirts_keywords).any?
      context["style"] = "sweatshirts"
    elsif (tokenized_array & tshirts_keywords).any?
      context["style"] = "t-shirts"
    end
    context
  end

  def answer(session, username, sender)
    if session.context["intent"].nil?
      sender.reply({text: "Hi, #{username} !"})
      cta_intent_message(sender)
    elsif session.context["intent"] = "categories"
       cta_categories_message(sender)
    elsif session.context["intent"] = "brands"

    elsif session.context["gender"] && session.context.count == 2
      sender.reply({text:"Which brand are you interested in ?"})
    elsif session.context["style"] && session.context.count == 3
      sender.reply({text:"Which brand are you interested in ?"})
    elsif session.context["brand"] && session.context.count == 3
      sender.reply({text:"Which style ?"})
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
