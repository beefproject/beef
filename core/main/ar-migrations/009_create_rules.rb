class CreateRules < ActiveRecord::Migration[6.0]
  def change
    create_table :rules do |t|
      t.text :name
      t.text :author
      t.text :browser
      t.text :browser_version
      t.text :os
      t.text :os_version
      t.text :modules
      t.text :execution_order
      t.text :execution_delay
      t.text :chain_mode
    end
  end
end
