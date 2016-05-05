TEXT_CHARACTER_LIMIT = 320

template = {
    'template_type': 'text',
    'value': {
        'text': ''
    }
}

class TextTemplate
    def initialize(self, text='', post_text='', limit=TEXT_CHARACTER_LIMIT)
        self.template = template['value']
        self.text = text
        self.post_text = post_text
        self.limit = limit
    end
    def set_text(self, text='')
        self.text = text
    end
    def set_post_text(self, post_text='')
        self.post_text = post_text
    end
    def set_limit(self, limit=TEXT_CHARACTER_LIMIT)
        self.limit = limit
    end
    def get_message(self)
        n = self.limit - len(self.post_text)
        if n > len(self.text)
            self.template['text'] = self.text + self.post_text
        else
            # append ellipsis (length = 3)
            self.template['text'] = self.text[:n-3].rsplit(' ', 1)[0] + '...' + self.post_text
        return self.template
    end
end
