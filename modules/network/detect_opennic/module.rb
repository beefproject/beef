#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_opennic < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'opennic_resource', 'ui_label' => 'What OpenNIC image resource to request', 'value' => 'http://be.libre/lang/flag/us.png' },
      { 'name' => 'timeout', 'ui_label' => 'Detection timeout', 'value' => '10000' }
    ]
  end

  def post_execute
    return if @datastore['result'].nil?

    save({ 'result' => @datastore['result'] })
  end
end
