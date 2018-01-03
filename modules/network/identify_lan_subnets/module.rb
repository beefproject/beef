#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
##
# Ported to BeEF from: http://browserhacker.com/code/Ch10/index.html
##

class Identify_lan_subnets < BeEF::Core::Command
  
  def self.options
    return [
        {'name' => 'timeout', 'ui_label' => 'Timeout for each request (ms)', 'value' => '500'}
    ]
  end
  
  def post_execute
    content = {}
    content['host'] = @datastore['host'] if not @datastore['host'].nil?
    content['hosts'] = @datastore['hosts'] if not @datastore['hosts'].nil?
    if content.empty?
      content['fail'] = 'No active hosts have been discovered.'
    end
    save content
  end

end
