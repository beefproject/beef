class CreateInterceptor < ActiveRecord::Migration[6.0]
  def change
    create_table :interceptors do |t|
      t.text :ip
      t.text :post_data
    end
  end
end
