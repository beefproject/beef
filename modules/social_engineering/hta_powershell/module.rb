#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Hta_powershell < BeEF::Core::Command

  def self.options

    host = BeEF::Core::Configuration.instance.get('beef.http.host')
    port = BeEF::Core::Configuration.instance.get('beef.http.port')
    ps_url = BeEF::Core::Configuration.instance.get('beef.extension.social_engineering.powershell.powershell_handler_url')

    return [
        {'name' => 'domain', 'ui_label' => 'Serving Domain (BeEF server)', 'value' => "http://#{host}:#{port}"},
        {'name' => 'ps_url', 'ui_label' => 'Powershell/HTA handler', 'value' => "#{ps_url}"}
    ]
  end

  def post_execute
    save({'result' => @datastore['result']})
  end

end
