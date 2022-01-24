class CreateExecutions < ActiveRecord::Migration[6.0]
  def change
    create_table :executions do |t|
      t.text :session_id
      t.integer :mod_count
      t.integer :mod_successful
      t.text :mod_body
      t.text :exec_time
      t.text :rule_token
      t.boolean :is_sent
      t.integer :rule_id
    end
  end
end
