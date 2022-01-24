class CreateNetworkHost < ActiveRecord::Migration[6.0]
  def change
    create_table :network_hosts do |t|
      t.references :hooked_browser
      t.text :ip
      t.text :hostname
      t.text :ntype
      t.text :os
      t.text :mac
      t.text :lastseen
    end
  end
end
