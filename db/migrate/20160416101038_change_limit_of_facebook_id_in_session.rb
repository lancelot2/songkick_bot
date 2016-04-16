class ChangeLimitOfFacebookIdInSession < ActiveRecord::Migration
  def change
    change_column :sessions, :facebook_id, :integer, limit: 8
  end
end
