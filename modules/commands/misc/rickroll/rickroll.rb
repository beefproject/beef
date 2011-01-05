module BeEF
module Modules
module Commands


class Rickroll < BeEF::Command

  #
  # Defines and set up the command module.
  #
  def initialize
    super({
      'Name' => 'Rickroll',
      'Description' => 'Overwrite the body of the page the victim is on with a full screen Rickroll.',
      'Category' => 'Misc',
      'Author' => 'Yori Kvitchko',
      'Data' =>
          [
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