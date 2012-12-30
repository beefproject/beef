#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
#
# DNS Enumeration

class Dns_enumeration < BeEF::Core::Command
  
  def self.options
    return [
        {'name' => 'dns_list', 'ui_label' => 'DNS (comma separated)', 'value' => '%default%'},
        {'name' => 'timeout', 'ui_label' => 'Timeout (ms)', 'value' => '4000'}
    ]
  end
  
  def post_execute
    content = {}
    content['result'] =@datastore['result'] if not @datastore['result'].nil?
    if content.empty?
      content['fail'] = 'No DNS hosts have been discovered.'
    end
    save content
  end
end
