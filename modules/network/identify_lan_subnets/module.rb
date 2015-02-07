#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
##
# Ported to BeEF from: http://browserhacker.com/code/Ch10/index.html
##

class Identify_lan_subnets < BeEF::Core::Command
  
  def self.options
    return [
        {'name' => 'timeout', 'ui_label' => 'Timeout for each request (ms)', 'value' => '500'}
    ]
  end
  
  def post_execute
    content = {}
    content['host'] = @datastore['host'] if not @datastore['host'].nil?
    content['hosts'] = @datastore['hosts'] if not @datastore['hosts'].nil?
    if content.empty?
      content['fail'] = 'No active hosts have been discovered.'
    end
    save content

    configuration = BeEF::Core::Configuration.instance
    if configuration.get("beef.extension.network.enable") == true

      session_id = @datastore['beefhook']
      cid = @datastore['cid'].to_i

      # log the network hosts
      if @datastore['results'] =~ /^hosts=([\d\.,]+)/
        hosts = "#{$1}"
        hosts.split(',').flatten.each do |ip|
          next if ip.nil?
          next unless ip.to_s =~ /^([\d\.]+)$/
          next unless BeEF::Filters.is_valid_ip?(ip)
          if BeEF::Core::Models::NetworkHost.all(:hooked_browser_id => session_id, :ip => ip).empty? # prevent duplicates
            print_debug("Hooked browser found host #{ip}")
            r = BeEF::Core::Models::NetworkHost.new(:hooked_browser_id => session_id, :ip => ip, :cid => cid)
            r.save
          end
        end
      end
    end

  end

end
