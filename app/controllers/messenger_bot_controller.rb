class MessengerBotController < ActionController::Base

  def find_or_create_session(fbid, max_age: 5.minutes)
    Session.find_by(["facebook_id = ? AND last_exchange >= ?", fbid, max_age.ago]) ||
    Session.create(facebook_id: fbid, context: {})
  end

  def gender_determination(msg, context)
    tokenized_array = msg.split.gsub(",", "")
    if (tokenized_array & men_keywords).any?
      context["gender"] = 263046279
    elsif (tokenized_array & women_keywords).any?
       context["gender"] = 263046151
    end
    context
  end

  def brand_determination(msg, context)
    tokenized_array = msg.split.gsub(",", "")
    if (tokenized_array & nike_keywords).any?
      context["gender"] = "nike"
    elsif (tokenized_array & adidas_keywords).any?
       context["gender"] = "adidas"
    end
    context
  end

  def style_determination(msg, context)
    tokenized_array = msg.split.gsub(",", "")
    if (tokenized_array & running_keywords).any?
      context["gender"] = "running"
    elsif (tokenized_array & lifestyle_keywords).any?
       context["gender"] = "lifestyle"
    end
    context
  end

  def wit_request(msg, sender, session)
    session.update(context: gender_determination(msg, session.context))
    session.update(context: brand_determination(msg, session.context))
    session.update(context: style_determination(msg, session.context))
    p session.context
    sender.reply({ text: msg })
  end

  def message(event, sender)
    msg = event["message"]["text"]
    sender_id = event["sender"]["id"]
    session = find_or_create_session(sender_id)
    session.update(last_exchange: Time.now)
    wit_request(msg, sender, session)
  end

  def postback(event, sender)
    msg = event["postback"]["payload"]
    sender_id = event["sender"]["id"]
    session = find_or_create_session(sender)
    session.update(last_exchange: Time.now)
  end
end
