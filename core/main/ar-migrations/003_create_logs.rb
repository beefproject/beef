class CreateLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :logs do |t|
      t.text :logtype
      t.text :event
      t.datetime :date
      t.references :hooked_browser
    end
  end
end
