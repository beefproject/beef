class CreateHookedBrowsers < ActiveRecord::Migration[6.0]
  def change
    create_table :hooked_browsers do |t|
      t.text :session
      t.text :ip
      t.text :firstseen
      t.text :lastseen
      t.text :httpheaders
      t.text :domain
      t.integer :port
      t.integer :count
      t.boolean :is_proxy
    end
  end
end
