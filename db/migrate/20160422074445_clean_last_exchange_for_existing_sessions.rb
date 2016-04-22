class CleanLastExchangeForExistingSessions < ActiveRecord::Migration
  def change
    execute("UPDATE sessions SET last_exchange = NOW()")
  end
end
