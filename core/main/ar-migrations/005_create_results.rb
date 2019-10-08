class CreateResults < ActiveRecord::Migration[6.0]

	def change

		create_table :results do |t|
			t.datetime :date
			t.integer :status
            t.text :data
		end

	end

end
