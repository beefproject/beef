class CreateRtcManage < ActiveRecord::Migration[6.0]
  def change
    create_table :rtc_manages do |t|
      t.references :hooked_browser
      t.text :message
      t.text :has_sent, default: 'waiting'
    end
  end
end
