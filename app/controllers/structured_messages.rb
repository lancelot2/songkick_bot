class StructuredMessages < ActionController::Base
  def cta_message
    sender.reply({
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text":"What do you want to do next?",
          "buttons":[
            {
              "type":"web_url",
              "url":"https://github.com/jun85664396/messenger-bot-rails",
              "title":"Show Website"
            },
            {
              "type":"postback",
              "title":"Start Chatting",
              "payload":"USER_DEFINED_PAYLOAD"
            }
          ]
        }
      }
    })
  end

  def generic_template_message(products, sender)
    structured_reply = {
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"generic",
          "elements": []
      }
    }
  }

    products["products"].each do |product|
      structured_reply["attachment"]["payload"]["elements"] <<
        { "title": product["title"],
          "image_url": product["images"].first["src"],
          "subtitle":"",
          "buttons":[
            {
              "type":"postback",
              "payload": "#{product["id"]}: info",
              "title":"More info"
            },
            {
              "type":"postback",
              "payload": "#{product["id"]}: stock",
              "title":"Check stock"
            },
            {
              "type":"postback",
              "title":"Similar items",
              "payload": "#{product["id"]}: similar"
            }
          ]
        }
    end
    sender.reply(structured_reply)
  end

  def receipt_message

  end

  def regular_message(sender, msg)

  end
end
