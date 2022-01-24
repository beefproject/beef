class CreateBrowserDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :browser_details do |t|
      t.text :session_id
      t.text :detail_key
      t.text :detail_value
    end
  end
end
