class CreateXssraysScan < ActiveRecord::Migration[6.0]
  def change
    create_table :xssraysscans do |t|
      t.references :hooked_browser
      t.datetime :scan_start
      t.datetime :scan_finish
      t.text :domain
      t.text :cross_domain
      t.integer :clean_timeout
      t.boolean :is_started
      t.boolean :is_finished
    end
  end
end
