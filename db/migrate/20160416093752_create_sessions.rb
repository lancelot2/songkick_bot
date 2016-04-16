class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.integer :facebook_id
      t.jsonb :context
      t.timestamps null: false
    end
  end
end
