class CreateCommands < ActiveRecord::Migration[6.0]
  def change
    create_table :commands do |t|
      t.references :command_module
      t.references :hooked_browser
      t.text :data
      t.datetime :creationdate
      t.text :label
      t.boolean :instructions_sent, default: false
    end
  end
end
