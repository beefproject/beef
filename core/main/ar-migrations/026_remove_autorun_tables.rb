class RemoveAutorunTables < ActiveRecord::Migration[6.0]
  def up
    drop_table :executions if table_exists?(:executions)
    drop_table :rules if table_exists?(:rules)
  end

  def down
    # Cannot recreate these tables - ARE functionality has been removed
    raise ActiveRecord::IrreversibleMigration
  end
end
