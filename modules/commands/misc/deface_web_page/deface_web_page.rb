module BeEF
module Modules
module Commands


class Deface_web_page < BeEF::Command

  #
  # Defines and set up the command module.
  #
  def initialize
    super({
      'Name' => 'Deface Web Page',
      'Description' => 'Overwrite the body of the page the victim is on with the "Deface Content" string',
      'Category' => 'Misc',
      'Author' => 'antisnatchor',
      'Data' => [
        { 'name' => 'deface_content', 'ui_label'=>'Deface Content', 'type' => 'textarea', 'value' =>'Defaced!', 'width' => '400px', 'height' => '100px' },
      ],
      'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_USER_NOTIFY, 
      'browser_name' =>     ALL
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