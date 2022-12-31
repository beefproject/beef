#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Fingerprint_routers < BeEF::Core::Command
  def self.options
    []
  end

  def post_execute
    content = {}
    content['results'] = @datastore['results'] unless @datastore['results'].nil?
    save content

    configuration = BeEF::Core::Configuration.instance
    return unless configuration.get('beef.extension.network.enable') == true

    case @datastore['results']
    when /^proto=(.+)&ip=(.+)&port=(\d+)&service=(.+)/
      proto = Regexp.last_match(1)
      ip = Regexp.last_match(2)
      port = Regexp.last_match(3)
      service = Regexp.last_match(4)
      session_id = @datastore['beefhook']
      if BeEF::Filters.is_valid_ip?(ip)
        print_debug("Hooked browser found network service #{service} [proto: #{proto}, ip: #{ip}, port: #{port}]")
        BeEF::Core::Models::NetworkService.create(hooked_browser_id: session_id, proto: proto, ip: ip, port: port, type: service)
      end
    when /^ip=(.+)&device=(.+)/
      ip = Regexp.last_match(1)
      device = Regexp.last_match(2)
      session_id = @datastore['beefhook']
      if BeEF::Filters.is_valid_ip?(ip)
        print_debug("Hooked browser found network device #{device} [ip: #{ip}]")
        BeEF::Core::Models::NetworkHost.create(hooked_browser_id: session_id, ip: ip, type: device)
      end
    end
  end
end
