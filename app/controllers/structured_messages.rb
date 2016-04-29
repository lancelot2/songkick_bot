class StructuredMessages < ActionController::Base
  def cta_intent_message(sender)
    sender.reply({
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text":"Do you want to browse through the brands or our categories ?",
          "buttons":[
            {
              "type":"postback",
              "title":"Categories",
              "payload":"category"
            },
            {
              "type":"postback",
              "title":"Brands",
              "payload":"brand"
            }
          ]
        }
      }
    })
  end

  def cta_categories_message(sender)
    sender.reply({
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text":"Which category do you want to look at ?",
          "buttons":[
            {
              "type":"postback",
              "title":"Running",
              "payload":"running"
            },
            {
              "type":"postback",
              "title":"Shirts",
              "payload":"shirts"
            },
            {
              "type":"postback",
              "title":"Sweatshirts",
              "payload":"sweatshirts"
            }
            # {
            #   "type":"postback",
            #   "title":"Sweatshirts",
            #   "payload":"sweatshirts"
            # },
            # {
            #   "type":"postback",
            #   "title":"Lifestyle",
            #   "payload":"lifestyle"
            # }
          ]
        }
      }
    })
  end

  def cta_brands_message(sender)
    sender.reply({
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text":"Which brand do you want to look at ?",
          "buttons":[
            {
              "type":"postback",
              "title":"Nike",
              "payload":"nike"
            },
            {
              "type":"postback",
              "title":"Adidas",
              "payload":"adidas"
            },
            {
              "type":"postback",
              "title":"Dedicated",
              "payload":"dedicated"
            }
            # {
            #   "type":"postback",
            #   "title":"Sweatshirts",
            #   "payload":"sweatshirts"
            # },
            # {
            #   "type":"postback",
            #   "title":"Lifestyle",
            #   "payload":"lifestyle"
            # }
          ]
        }
      }
    })
  end


  def generic_template_message(products, sender)
    structured_reply = {
      "attachment":{
        "type": "template",
        "payload":{
          "template_type": "generic",
          "elements": []
        }
      }
    }

    products["products"][0..2].each do |product|
      structured_reply[:attachment][:payload][:elements] <<
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
            }
            # {
            #   "type":"postback",
            #   "title":"Similar items",
            #   "payload": "#{product["id"]}: similar"
            # }
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
