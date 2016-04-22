class AddLastExchangeToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :last_exchange, :datetime
  end
end
