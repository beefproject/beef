class Test_return_long_string < BeEF::Core::Command
  
  def initialize
    super({
      'Name' => 'Return Long String',
      'Description' => %Q{
        This module will return a string of the specified length.
        },
      'Category' => 'Debug',
      'Data' => [
        {'name' => 'repeat', 'ui_label' => 'Times to repeat', 'value' =>'1024'},
        {'name' => 'repeat_string', 'ui_label' => 'String to repeat', 'value' =>'\u00AE'}
      ],
      'Author' => ['wade'],
      'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_WORKING, 
      'browser_name' =>     ALL
    })

    use_template!
  end
  
  def callback
    content = {}
    content['Result String'] = @datastore['result_string']
    save content
  end

end
