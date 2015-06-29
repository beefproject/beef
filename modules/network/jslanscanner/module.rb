#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Fingerprint_routers < BeEF::Core::Command
  
  def self.options
    return [
    ]
  end
  
  def post_execute
    content = {}
    content['results'] = @datastore['results'] if not @datastore['results'].nil?
    save content

    configuration = BeEF::Core::Configuration.instance
    if configuration.get("beef.extension.network.enable") == true
      if @datastore['results'] =~ /^proto=(.+)&ip=(.+)&port=([\d]+)&service=(.+)/
        proto = $1
        ip = $2
        port = $3
        service = $4
        session_id = @datastore['beefhook']
        cid = @datastore['cid'].to_i
        if BeEF::Filters.is_valid_ip?(ip)
          print_debug("Hooked browser found network service " + service + " [proto: #{proto}, ip: #{ip}, port: #{port}]")
          BeEF::Core::Models::NetworkService.add(:hooked_browser_id => session_id, :proto => proto, :ip => ip, :port => port, :type => service, :cid => cid)
        end
      elsif @datastore['results'] =~ /^ip=(.+)&device=(.+)/
        ip = $1
        device = $2
        session_id = @datastore['beefhook']
        cid = @datastore['cid'].to_i
        if BeEF::Filters.is_valid_ip?(ip)
          print_debug("Hooked browser found network device " + device + " [ip: #{ip}]")
          BeEF::Core::Models::NetworkHost.add(:hooked_browser_id => session_id, :ip => ip, :type => device, :cid => cid)
        end
      end
    end

  end
end
