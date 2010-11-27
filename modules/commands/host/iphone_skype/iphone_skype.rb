module BeEF
module Modules
module Commands


class Iphone_skype < BeEF::Command

  #
  # Defines and set up the command module.
  #
  def initialize
    super({
      'Name' => 'iPhone Skype URL',
      'Description' => 'Utilise Nitesh Dhanjani\'s Insecure Handling of URL Schemes in iOS to try and make the browser execute a skype call',
      'Category' => 'Host',
      'Author' => 'xntrik',
      'Data' =>
          [
              [   'name' => 'tel_num',
                  'ui_label'=>'Skype Number',
                  'value' =>'5551234',
                  'width' => '200px'
              ],
          ],
      'File' => __FILE__,
      'Target' => {
        'browser_name' =>     BeEF::Constants::Browsers::S
      }
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
