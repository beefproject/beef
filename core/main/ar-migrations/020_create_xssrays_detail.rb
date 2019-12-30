class CreateXssraysDetail < ActiveRecord::Migration[6.0]

	def change

		create_table :xssrays_details do |t|
            t.references :hooked_browser
            t.text :vector_name
            t.text :vector_method
            t.text :vector_poc
		end

	end

end
