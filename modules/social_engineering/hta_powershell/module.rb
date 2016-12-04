#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Hta_powershell < BeEF::Core::Command

  def self.options

    @configuration = BeEF::Core::Configuration.instance
    proto = @configuration.get("beef.http.https.enable") == true ? "https" : "http"
    beef_host = @configuration.get("beef.http.public") || @configuration.get("beef.http.host")
    beef_port = @configuration.get("beef.http.public_port") || @configuration.get("beef.http.port")
    base_host = "#{proto}://#{beef_host}:#{beef_port}"

    ps_url = @configuration.get('beef.extension.social_engineering.powershell.powershell_handler_url')

    return [
        {'name' => 'domain', 'ui_label' => 'Serving Domain (BeEF server)', 'value' => "#{base_host}" },
        {'name' => 'ps_url', 'ui_label' => 'Powershell/HTA handler', 'value' => "#{ps_url}"}
    ]
  end

  def post_execute
    save({'result' => @datastore['result']})
  end

end
