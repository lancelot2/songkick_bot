class StructuredMessages
  def cta_message

  end

  def generic_template_message(product)
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

  def receipt_message

  end
end
