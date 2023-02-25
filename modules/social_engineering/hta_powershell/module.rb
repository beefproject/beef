#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Hta_powershell < BeEF::Core::Command
  def self.options
    @config = BeEF::Core::Configuration.instance
    ps_url = @config.get('beef.extension.social_engineering.powershell.powershell_handler_url')

    [
      { 'name' => 'domain', 'ui_label' => 'Serving Domain (BeEF server)', 'value' => @config.beef_url_str },
      { 'name' => 'ps_url', 'ui_label' => 'Powershell/HTA handler', 'value' => ps_url }
    ]
  end

  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
