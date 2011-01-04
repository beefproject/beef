module BeEF
module Modules
module Commands

class Detect_details < BeEF::Command
  
  def initialize
    super({
      'Name' => 'Browser Details',
      'Description' => %Q{
        This module will retrieve the selected zombie browser plugins, browser type
        and scripting engines, plus screen dimensions.'
        },
      'Category' => 'Browser',
      'Author' => ['wade','vo','passbe'],
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
    content['Plugins'] = @datastore['plugins']
    content['Browser type'] = @datastore['browser_type']
    content['Java enabled'] =  @datastore['java_enabled']
    content['VBscript enabled'] = @datastore['vbscript_enabled']
    content['Has Flash'] = @datastore['has_flash']
    content['Has Google Gears'] = @datastore['has_googlegears']
    content['Screen Parameters'] = @datastore['screen_params']
    content['Window Size'] = @datastore['window_size']
    
    save content
    #update_zombie!
  end
  
end

end
end
end