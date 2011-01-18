module BeEF
module Modules
module Commands


class Alert_dialog < BeEF::Command
  
  #
  # Defines and set up the command module.
  #
  def initialize
    super({
      'Name' => 'Alert Dialog',
      'Description' => 'Sends an alert dialog to the victim',
      'Category' => 'Misc',
      'Author' => 'bm',
      'Data' => [
        {'name' => 'text', 'ui_label'=>'Alert text', 'type' => 'textarea', 'value' =>'BeEF', 'width' => '400px', 'height' => '100px'}
      ],
      'File' => __FILE__
    })
    
    set_target({
      'verified_status' =>  VERIFIED_USER_NOTIFY, 
      'browser_name' =>     ALL
    })
    
    # This tells the framework to use the file 'alert.js' as the command module instructions.
    use_template!
  end
  
  def callback
    content = {}
    content['User Response'] = "The user clicked the 'OK' button when presented with an alert box saying: '"
    content['User Response'] += @datastore['text'] + "'"
    save content
  end
  
end

end
end
end