class CreateAutoloader < ActiveRecord::Migration[6.0]

	def change

		create_table :autoloader do |t|
            t.references :command
            t.boolean :in_use
		end

	end

end
