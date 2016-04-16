class AddSessionIdToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :session_id, :integer, limit: 8
  end
end
