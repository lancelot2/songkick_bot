class ChangeLimitOfSessionIdInSession < ActiveRecord::Migration
  def change
    change_column :sessions, :session_id, :integer, limit: 8
  end
end
