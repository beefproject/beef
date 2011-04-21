class Test_return_ascii_chars < BeEF::Core::Command
  
  def initialize
    super({
      'Name' => 'Return Ascii Chars',
      'Description' => %Q{
        This module will return the set of ascii chars.
        },
      'Category' => 'Debug',
      'Data' => [
#        {'name' => 'repeat', 'ui_label' => 'Times to repeat', 'value' =>'1024'},
#        {'name' => 'repeat_string', 'ui_label' => 'String to repeat', 'value' =>'\u00AE'}
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
