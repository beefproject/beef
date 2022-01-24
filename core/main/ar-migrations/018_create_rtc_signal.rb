class CreateRtcSignal < ActiveRecord::Migration[6.0]
  def change
    create_table :rtc_signals do |t|
      t.references :hooked_browser
      t.integer :target_hooked_browser_id
      t.text :signal
      t.text :has_sent, default: 'waiting'
    end
  end
end
