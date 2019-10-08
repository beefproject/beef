class CreateCommands < ActiveRecord::Migration[6.0]

	def change

		create_table :commands do |t|
			t.text :data
			t.datetime :creationdate
			t.text :label
			t.boolean :instructions_sent
		end

	end

end
