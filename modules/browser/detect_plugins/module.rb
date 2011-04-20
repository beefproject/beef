class Detect_plugins < BeEF::Core::Command
  
  def initialize
    super({
      'Name' => 'Installed Plugins',
      'Description' => %Q{
        This module will retrieve the selected zombie browser plugins.'
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
    content['Plugins'] = @datastore['plugins']
    
    save content
    #update_zombie!
  end
  
end