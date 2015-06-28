#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_internal_ip_webrtc < BeEF::Core::Command

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content

    configuration = BeEF::Core::Configuration.instance
    if configuration.get("beef.extension.network.enable") == true
      session_id = @datastore['beefhook']
      cid = @datastore['cid'].to_i
      # save the network host
      if @datastore['results'] =~ /IP is ([\d\.,]+)/
        ips = $1.to_s.split(/,/)
        if !ips.nil? && !ips.empty?
          os = BeEF::Core::Models::BrowserDetails.get(session_id, 'OsName')
          ips.uniq.each do |ip|
            next unless ip =~ /^[\d\.]+$/
            next if ip =~ /^0\.0\.0\.0$/
            next unless BeEF::Filters.is_valid_ip?(ip)
            print_debug("Hooked browser has network interface #{ip}")
            BeEF::Core::Models::NetworkHost.add(:hooked_browser_id => session_id, :ip => ip, :os => os, :cid => cid)
          end
        end
      end
    end
  end

end
