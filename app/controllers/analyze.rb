class Analyze < ActionController::Base

  def intent_determination(msg, context)
    shoes_keywords = ["shoes"]
    tokenized_array = msg.split
    if (tokenized_array & men_keywords).any?
      context["intent"] = "shoes"
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
    tokenized_array = msg.split
    if (tokenized_array & running_keywords).any?
      context["style"] = "running"
    elsif (tokenized_array & lifestyle_keywords).any?
       context["style"] = "lifestyle"
    end
    context
  end

  def answer(session, username)
    if session.context.count == 1
      "Hi, #{username} ! Do you want shoes for men or women ?"
    elsif session.context["gender"] && session.context.count == 2
      "Which brand are you interested in ?"
    elsif session.context["style"] && session.context.count == 3
      "Which brand ?"
    elsif session.context["brand"] && session.context.count == 3
      "Which style ?"
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
