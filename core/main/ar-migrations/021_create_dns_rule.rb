class CreateDnsRule < ActiveRecord::Migration[6.0]
  def change
    create_table :dns_rules do |t|
      t.text :pattern
      t.text :resource
      t.text :response
      t.text :callback
    end
  end
end
