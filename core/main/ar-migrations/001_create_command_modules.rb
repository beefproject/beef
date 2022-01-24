class CreateCommandModules < ActiveRecord::Migration[6.0]
  def change
    create_table :command_modules do |t|
      t.text :name
      t.text :path
    end
  end
end
