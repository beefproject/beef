#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Coinhive_miner < BeEF::Core::Command
  def self.options
    [{ 'name'        => 'public_token',
       'description' => 'Public Token',
       'ui_label'    => 'Public Token',
       'value'       => 'Ofh5MIvjuCBDqwJ9TCTio7TYko0ig5TV',
       'type'        => 'text' }]
  end
  def post_execute
    save({'result' => @datastore['result']})
  end
end
