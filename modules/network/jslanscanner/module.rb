#
# Copyright (c) 2006-2024 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
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

    session_id = @datastore['beefhook']
    hooked_browser = BeEF::Core::Models::HookedBrowser.where(session: session_id).first
      
    case @datastore['results']
    when /^proto=(.+)&ip=(.+)&port=(\d+)&service=(.+)/
      proto = Regexp.last_match(1)
      ip = Regexp.last_match(2)
      port = Regexp.last_match(3)
      service = Regexp.last_match(4)
      if BeEF::Filters.is_valid_ip?(ip)
        print_debug("Hooked browser found network service #{service} [proto: #{proto}, ip: #{ip}, port: #{port}]")
        BeEF::Core::Models::NetworkService.create(hooked_browser: hooked_browser, proto: proto, ip: ip, port: port, ntype: service)
      end
    when /^ip=(.+)&device=(.+)/
      ip = Regexp.last_match(1)
      device = Regexp.last_match(2)
      
      if BeEF::Filters.is_valid_ip?(ip)
        print_debug("Hooked browser found network device #{device} [ip: #{ip}]")
        BeEF::Core::Models::NetworkHost.create(hooked_browser: hooked_browser, ip: ip, type: device)
      end
    end
  end
end
