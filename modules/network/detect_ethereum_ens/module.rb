#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_ethereum_ens < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'ethereum_ens_resource', 'ui_label' => 'What Ethereum ENS image resource to request', 'value' => 'http://ens.eth/static/favicon-6305d6ce89910df001b94e8a31eb08f5.ico' },
      # Alternatives:
      # http://esteroids.eth/favicon.ico
      # http://api3.eth/api3-logo-white.svg
      # http://api3.eth/favicon.ico
      { 'name' => 'timeout', 'ui_label' => 'Detection timeout', 'value' => '15000' }
    ]
  end

  def post_execute
    return if @datastore['result'].nil?

    save({ 'result' => @datastore['result'] })
  end
end
