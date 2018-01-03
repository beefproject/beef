#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_ntop_network_hosts < BeEF::Core::Command

  def self.options
    return [
      { 'name' => 'rhost', 'ui_label' => 'Remote Host', 'value' => '127.0.0.1' },
      { 'name' => 'rport', 'ui_label' => 'Remote Port', 'value' => '3000' }
    ]
  end

  def post_execute
    save({'result' => @datastore['result']})

    configuration = BeEF::Core::Configuration.instance
    if configuration.get("beef.extension.network.enable") == true
      if @datastore['results'] =~ /^proto=(https?)&ip=([\d\.]+)&port=([\d]+)&data=(.+)\z/
        proto = $1
        ip = $2
        port = $3
        data = $4
        session_id = @datastore['beefhook']
        type = 'ntop'
        if BeEF::Filters.is_valid_ip?(ip)
          print_debug("Hooked browser found 'ntop' [proto: #{proto}, ip: #{ip}, port: #{port}]")
          BeEF::Core::Models::NetworkService.add(:hooked_browser_id => session_id, :proto => proto, :ip => ip, :port => port, :type => type)
        end
        data.to_s.scan(/"hostNumIpAddress":"([\d\.]+)"/).flatten.each do |ip|
          if BeEF::Filters.is_valid_ip?(ip)
            print_debug("Hooked browser found host #{ip}")
            BeEF::Core::Models::NetworkHost.add(:hooked_browser_id => session_id, :ip => ip, :port => port)
          end
        end
      end
    end
  end

end

