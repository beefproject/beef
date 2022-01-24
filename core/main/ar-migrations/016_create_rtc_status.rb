class CreateRtcStatus < ActiveRecord::Migration[6.0]
  def change
    create_table :rtc_statuss do |t|
      t.references :hooked_browser
      t.integer :target_hooked_browser_id
      t.text :status
    end
  end
end
