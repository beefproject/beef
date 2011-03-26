module BeEF
module Modules
module Commands

class Detect_screen_details < BeEF::Command
  
  def initialize
    super({
      'Name' => 'Screen Details',
      'Description' => %Q{
        This module will retrieve the selected zombie screen dimensions.'
        },
      'Category' => 'Browser',
      'Author' => ['wade','vo','passbe','saafan'],
      'File' => __FILE__
    })
    
    set_target({
        'verified_status' =>  VERIFIED_WORKING, 
        'browser_name' =>     ALL
    })
    
    use 'beef.dom'
    use_template!
  end

  def callback
    content = {}
    content['Screen Parameters'] = @datastore['screen_params']
    content['Window Size'] = @datastore['window_size']
    
    save content
    #update_zombie!
  end
  
end

end
end
end