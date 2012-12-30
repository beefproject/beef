#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Insecure_url_skype < BeEF::Core::Command

  def self.options
    return [{
      'name' => 'tel_num',
      'description' => 'The telephone number to dial',
      'ui_label'=>'Number',
      'value' =>'5551234',
      'width' => '200px'
      }]
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content

  end

end
