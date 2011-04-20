class Detect_scripts_support < BeEF::Core::Command
  
  def initialize
    super({
      'Name' => 'Scripts Support',
      'Description' => %Q{
        This module will retrieve the selected zombie browser scripting engines.'
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
    content['Java enabled'] =  @datastore['java_enabled']
    content['VBscript enabled'] = @datastore['vbscript_enabled']
    content['Has Flash'] = @datastore['has_flash']
    content['Has Google Gears'] = @datastore['has_googlegears']
    
    save content
    #update_zombie!
  end
  
end