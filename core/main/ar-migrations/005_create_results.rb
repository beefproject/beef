class CreateResults < ActiveRecord::Migration[6.0]
  def change
    create_table :results do |t|
      t.references :command
      t.references :hooked_browser
      t.datetime :date
      t.integer :status
      t.text :data
    end
  end
end
