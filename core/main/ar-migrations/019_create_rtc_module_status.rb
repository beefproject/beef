class CreateRtcModuleStatus < ActiveRecord::Migration[6.0]
  def change
    create_table :rtc_module_statuss do |t|
      t.references :hooked_browser
      t.references :command_module
      t.integer :target_hooked_browser_id
      t.text :status
    end
  end
end
