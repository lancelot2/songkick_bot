# template = {
#     'template_type': 'button',
#     'value': {
#         'attachment': {
#             'type': 'template',
#             'payload': {
#                 'template_type': 'button',
#                 'text': '',
#                 'buttons': []
#             }
#         }
#     }
# }

# class ButtonTemplate:
#     def initialize(self, text=''):
#         self.template = template['value']
#         self.text = text
#     end
#     def add_web_url(self, title='', url='')
#         web_url_button = {}
#         web_url_button['type'] = 'web_url'
#         web_url_button['title'] = title
#         web_url_button['url'] = url
#         self.template['attachment']['payload']['buttons'].append(web_url_button)
#     end

#     def add_postback(self, title='', payload='')
#         postback_button = {}
#         postback_button['type'] = 'postback'
#         postback_button['title'] = title
#         postback_button['payload'] = payload
#         self.template['attachment']['payload']['buttons'].append(postback_button)
#     end

#     def set_text(self, text='')
#         self.text = text
#     end

#     def get_message(self)
#         self.template['attachment']['payload']['text'] = self.text
#         return self.template
#     end
# end
