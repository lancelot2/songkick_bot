class Session < ActiveRecord::Base
  before_create :set_last_exchange_to_now
  def set_last_exchange_to_now
    self.last_exchange = Time.now
  end
end
