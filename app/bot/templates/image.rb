template = {
    'template_type': 'image',
    'value': {
        'attachment': {
            'type': 'image',
            'payload': {
                'url': ''
            }
        }
    }
}

class ImageTemplate
    def initialize(self, url='')
        self.template = template['value']
        self.url = url
    end

    def set_url(self, url='')
        self.url = url
    end

    def get_message(self)
        self.template['attachment']['payload']['url'] = self.url
        return self.template
    end
end
