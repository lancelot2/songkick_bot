# class TelegramController < ApplicationController
#   require 'telegram/bot'
#   skip_before_action :verify_authenticity_token




#   def reception
#     require 'telegram/bot'
# token = '185608577:AAGrm70H1VlXnd3A8mEE6KbGWlqUNPGFPPc'


# Telegram::Bot::Client.run(token) do |bot|
#   bot.listen do |message|
#       bot.api.send_message(chat_id: message.chat.id, text: "I am the SitePoint bot, My commands are /sitepoint /map")
#       bot.api.send_message(chat_id: message.chat.id, text: "Welcome to http://sitepoint.com")
#       bot.api.send_location(chat_id: message.chat.id, latitude: -37.807416, longitude: 144.985339)
#    end
#   end
# end

#     # access_token = "RNZ5ICWG3RUKRKT7ZNUSGCVIDB6CHGAT"
#     # token = '185608577:AAGrm70H1VlXnd3A8mEE6KbGWlqUNPGFPPc'
#     # recipientId = 0
#     # @actions = {}
#     # @actions = {
#     #   :say => -> (session_id, context, msg) {
#     #      bot.api.send_message(chat_id: message.chat.id, text: msg)
#     #   },
#     #   :merge => -> (session_id, context, entities, msg) {
#     #     return context
#     #   },
#     #   :error => -> (session_id, context, error) {
#     #     p 'Oops I don\'t know what to do.'
#     #   },
#     # }
#     # client = Wit.new access_token, @actions


#     # Telegram::Bot::Client.run(token) do |bot|
#     #   bot.listen do |message|
#     #   session = rand(1..10000)
#     #   client.run_actions session, message, {}
#     #   end
#     # end
#   end
# end


