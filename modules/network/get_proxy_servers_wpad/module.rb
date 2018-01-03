#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_proxy_servers_wpad < BeEF::Core::Command

  def post_execute
    save({'result' => @datastore['result']})

    configuration = BeEF::Core::Configuration.instance
    return unless configuration.get("beef.extension.network.enable") == true
    session_id = @datastore['beefhook']
    if @datastore['results'] =~ /^proxies=(.+)$/
      proxies = $1.to_s
      proxies.split(',').uniq.each do |proxy|
        if proxy =~ /^(SOCKS|PROXY)\s+([\d\.]+:[\d]{1,5})/
          proxy_type = "#{$1}"
          ip = $2.to_s.split(':')[0]
          port = $2.to_s.split(':')[1]
          proto = 'HTTP' if proxy_type =~ /PROXY/
          proto = 'SOCKS' if proxy_type =~ /SOCKS/
          if BeEF::Filters.is_valid_ip?(ip)
            print_debug("Hooked browser found #{proto} proxy [ip: #{ip}, port: #{port}]")
            BeEF::Core::Models::NetworkService.add(:hooked_browser_id => session_id, :proto => proto.downcase, :ip => ip, :port => port, :type => "#{proto} Proxy")
          end
        end
      end
    end
  end

end

