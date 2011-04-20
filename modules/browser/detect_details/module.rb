class Detect_details < BeEF::Core::Command
  
  def initialize
    super({
      'Name' => 'Browser Type',
      'Description' => %Q{
        This module will retrieve the selected zombie browser details.'
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
    content['Browser type'] = @datastore['browser_type']    
    
    save content
    #update_zombie!
  end
  
end