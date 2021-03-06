class StructuredMessage

  def initialize
  end

  def cta_intent_message(sender)
    sender.reply({
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text":"Do you want to browse through the brands, our categories or by price range?",
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
            },
            {
              "type":"postback",
              "title":"Price range",
              "payload":"pricerange"
            }
          ]
        }
      }
    })
  end

  def cta_restart_message(sender)
    sender.reply({
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text":"What do you want to do now:",
          "buttons":[
            {
              "type":"postback",
              "title":"Back to the main browsing menu",
              "payload":"mainbrowsing"
            },
            {
              "type":"postback",
              "title":"Back to your filtered selection",
              "payload":"filtered"
            },
            {
              "type":"postback",
              "title":"Back to the product description",
              "payload":"productdescription"
            }
          ]
        }
      }
    })
  end

  def cta_stock_left_message(sender, product_stock)
    sender.reply({
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text": "We have #{product_stock} pairs left. Should I book one for you ?",
          "buttons":[
            {
              "type":"postback",
              "title":"Yes",
              "payload":"yes :stock_left"
            },
            {
              "type":"postback",
              "title":"No",
              "payload":"no :stock_left"
            }
          ]
        }
      }
    })
  end

  def cta_delivery_message(sender)
    sender.reply({
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text": "Done. How do you want to proceed: ",
          "buttons":[
            {
              "type":"postback",
              "title":"Get delivered at my place",
              "payload":"delivery"
            },
            {
              "type":"postback",
              "title":"Pick up in store",
              "payload":"pickup"
            }
          ]
        }
      }
    })
  end

  def cta_sizes_choice_message(sender)
    sender.reply({
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text": "Type a size in particular or hit 'All sizes'",
          "buttons":[
            {
              "type":"postback",
              "title":"All sizes",
              "payload":"allsizes"
            },
          ]
        }
      }
    })
  end


  def cta_no_stock_left_message(sender)
    sender.reply({
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text": "We don't have any pairs left. Should I notify you when we'll receive one?",
          "buttons":[
            {
              "type":"postback",
              "title":"Yes",
              "payload":"yes :nostock_left"
            },
            {
              "type":"postback",
              "title":"Brands",
              "payload":"no :nostock_left"
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
          ]
        }
      }
    })
  end

  def cta_pricerange_message(sender)
    sender.reply({
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text":"So what is your budget ?",
          "buttons":[
            {
              "type":"postback",
              "title":"Less than 20 euros",
              "payload":"less20"
            },
            {
              "type":"postback",
              "title":"From 20 to 50 euros",
              "payload":"20to50"
            },
            {
              "type":"postback",
              "title":"More than 50 euros",
              "payload":"more50"
            }
          ]
        }
      }
    })
  end

   def price_filtered_message(products, sender, min, max)
    structured_reply = {
      "attachment":{
        "type": "template",
        "payload":{
          "template_type": "generic",
          "elements": []
        }
      }
    }

    products["products"].each do |product|
      if product["variants"].first["price"].to_i < max  && product["variants"].first["price"].to_i > min
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
                "payload": "#{product["id"]}: sizes",
                "title":"Check size availabilities"
              }
            ]
          }
        end
    end
    sender.reply(structured_reply)
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
          ]
        }
    end
    sender.reply(structured_reply)
  end

    def more_info_message(product, sender)
    structured_reply = {
      "attachment":{
        "type": "template",
        "payload":{
          "template_type": "generic",
          "elements": []
        }
      }
    }

    product["product"]["images"].each do |image|
      structured_reply[:attachment][:payload][:elements] <<
        { "title": "Detailed images",
          "image_url": image["src"]
        }
    end
    sender.reply(structured_reply)
    sleep(2)
    sender.reply({
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"button",
          "text": "Do you want to check the size availabilities ?",
          "buttons":[
            {
              "type":"postback",
              "title":"Yes",
              "payload":"sizes"
            },
            {
              "type":"postback",
              "title":"No",
              "payload":"nosizes"
            }
          ]
        }
      }
    })
  end


  def receipt_message

  end

  def regular_message(sender, msg)

  end
end
