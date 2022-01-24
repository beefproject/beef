class CreateWebCloner < ActiveRecord::Migration[6.0]
  def change
    create_table :web_cloners do |t|
      t.text :uri
      t.text :mount
    end
  end
end
