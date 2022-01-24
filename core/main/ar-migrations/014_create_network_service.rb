class CreateNetworkService < ActiveRecord::Migration[6.0]
  def change
    create_table :network_services do |t|
      t.references :hooked_browser
      t.text :proto
      t.text :ip
      t.text :port
      t.text :ntype
    end
  end
end
