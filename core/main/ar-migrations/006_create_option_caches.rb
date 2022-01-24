class CreateOptionCaches < ActiveRecord::Migration[6.0]
  def change
    create_table :option_caches do |t|
      t.text :name
      t.text :value
    end
  end
end
