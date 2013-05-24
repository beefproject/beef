#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
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
          if not @data['results']['HostName'].nil? then
            log_zombie_domain=@data['results']['HostName']
          elsif (not @data['request'].referer.nil?) and (not @data['request'].referer.empty?)
            log_zombie_domain=@data['request'].referer.gsub('http://', '').gsub('https://', '').split('/')[0]
          else
            log_zombie_domain="unknown" # Probably local file open
          end

          # port
          if not @data['results']['HostPort'].nil? then
            log_zombie_port=@data['results']['HostPort']
          else
            log_zombie_domain_parts=log_zombie_domain.split(':')
            log_zombie_port=80
            if log_zombie_domain_parts.length > 1 then
              log_zombie_port=log_zombie_domain_parts[1].to_i
            end
          end

          zombie.domain = log_zombie_domain
          zombie.port = log_zombie_port

          #Parse http_headers. Unfortunately Rack doesn't provide a util-method to get them :(
          @http_headers = Hash.new
          http_header = @data['request'].env.select {|k,v| k.to_s.start_with? 'HTTP_'}
                      .each {|key,value|
                            @http_headers[key.sub(/^HTTP_/, '')] = value
                      }
          zombie.httpheaders = @http_headers.to_json
          zombie.save

          # add a log entry for the newly hooked browser
          BeEF::Core::Logger.instance.register('Zombie', "#{zombie.ip} just joined the horde from the domain: #{log_zombie_domain}:#{log_zombie_port.to_s}", "#{zombie.id}")
          # get and store browser name
          browser_name = get_param(@data['results'], 'BrowserName')
          if BeEF::Filters.is_valid_browsername?(browser_name)
            BD.set(session_id, 'BrowserName', browser_name)
          else
            self.err_msg "Invalid browser name returned from the hook browser's initial connection."
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

          # get and store the cookies
          cookies = get_param(@data['results'], 'Cookies')
          if BeEF::Filters.is_valid_cookies?(cookies)
            BD.set(session_id, 'Cookies', cookies)
          else
            self.err_msg "Invalid cookies returned from the hook browser's initial connection."
          end

          # get and store the os name
          os_name = get_param(@data['results'], 'OsName')
          if BeEF::Filters.is_valid_osname?(os_name)
            BD.set(session_id, 'OsName', os_name)
          else
            self.err_msg "Invalid operating system name returned from the hook browser's initial connection."
          end

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

          # get and store the yes|no value for JavaEnabled
          java_enabled = get_param(@data['results'], 'JavaEnabled')
          if BeEF::Filters.is_valid_yes_no?(java_enabled)
            BD.set(session_id, 'JavaEnabled', java_enabled)
          else
            self.err_msg "Invalid value for JavaEnabled returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for VBScriptEnabled
          vbscript_enabled = get_param(@data['results'], 'VBScriptEnabled')
          if  BeEF::Filters.is_valid_yes_no?(vbscript_enabled)
            BD.set(session_id, 'VBScriptEnabled', vbscript_enabled)
          else
            self.err_msg "Invalid value for VBScriptEnabled returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for HasFlash
          has_flash = get_param(@data['results'], 'HasFlash')
          if BeEF::Filters.is_valid_yes_no?(has_flash)
            BD.set(session_id, 'HasFlash', has_flash)
          else
            self.err_msg "Invalid value for HasFlash returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for HasPhonegap
          has_phonegap = get_param(@data['results'], 'HasPhonegap')
          if BeEF::Filters.is_valid_yes_no?(has_phonegap)
            BD.set(session_id, 'HasPhonegap', has_phonegap)
          else
            self.err_msg "Invalid value for HasPhonegap returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for HasGoogleGears
          has_googlegears = get_param(@data['results'], 'HasGoogleGears')
          if BeEF::Filters.is_valid_yes_no?(has_googlegears)
            BD.set(session_id, 'HasGoogleGears', has_googlegears)
          else
            self.err_msg "Invalid value for HasGoogleGears returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for HasFoxit
          has_foxit = get_param(@data['results'], 'HasFoxit')
          if BeEF::Filters.is_valid_yes_no?(has_foxit)
            BD.set(session_id, 'HasFoxit', has_foxit)
          else
            self.err_msg "Invalid value for HasFoxit returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for HasWebSocket
          has_web_socket = get_param(@data['results'], 'HasWebSocket')
          if BeEF::Filters.is_valid_yes_no?(has_web_socket)
            BD.set(session_id, 'HasWebSocket', has_web_socket)
          else
            self.err_msg "Invalid value for HasWebSocket returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for HasWebRTC
          has_webrtc = get_param(@data['results'], 'HasWebRTC')
          if BeEF::Filters.is_valid_yes_no?(has_webrtc)
            BD.set(session_id, 'HasWebRTC', has_webrtc)
          else
            self.err_msg "Invalid value for HasWebRTC returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for HasActiveX
          has_activex = get_param(@data['results'], 'HasActiveX')
          if BeEF::Filters.is_valid_yes_no?(has_activex)
            BD.set(session_id, 'HasActiveX', has_activex)
          else
            self.err_msg "Invalid value for HasActiveX returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for HasSilverlight
          has_silverlight = get_param(@data['results'], 'HasSilverlight')
          if BeEF::Filters.is_valid_yes_no?(has_silverlight)
            BD.set(session_id, 'HasSilverlight', has_silverlight)
          else
            self.err_msg "Invalid value for HasSilverlight returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for HasQuickTime
          has_quicktime = get_param(@data['results'], 'HasQuickTime')
          if BeEF::Filters.is_valid_yes_no?(has_quicktime)
            BD.set(session_id, 'HasQuickTime', has_quicktime)
          else
            self.err_msg "Invalid value for HasQuickTime returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for HasRealPlayer
          has_realplayer = get_param(@data['results'], 'HasRealPlayer')
          if BeEF::Filters.is_valid_yes_no?(has_realplayer)
            BD.set(session_id, 'HasRealPlayer', has_realplayer)
          else
            self.err_msg "Invalid value for HasRealPlayer returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for HasWMP
          has_wmp = get_param(@data['results'], 'HasWMP')
          if BeEF::Filters.is_valid_yes_no?(has_wmp)
            BD.set(session_id, 'HasWMP', has_wmp)
          else
            self.err_msg "Invalid value for HasWMP returned from the hook browser's initial connection."
          end

          # get and store the yes|no value for HasVLC
          has_vlc = get_param(@data['results'], 'HasVLC')
          if BeEF::Filters.is_valid_yes_no?(has_vlc)
            BD.set(session_id, 'HasVLC', has_vlc)
          else
            self.err_msg "Invalid value for HasVLC returned from the hook browser's initial connection."
          end

          # get and store the value for CPU
          cpu_type = get_param(@data['results'], 'CPU')
          if !cpu_type.nil?
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

          # get and store whether the browser has session cookies enabled
          has_session_cookies = get_param(@data['results'], 'hasSessionCookies')
          if BeEF::Filters.is_valid_yes_no?(has_session_cookies)
            BD.set(session_id, 'hasSessionCookies', has_session_cookies)
          else
            self.err_msg "Invalid value for hasSessionCookies returned from the hook browser's initial connection."
          end

          # get and store whether the browser has persistent cookies enabled
          has_persistent_cookies = get_param(@data['results'], 'hasPersistentCookies')
          if BeEF::Filters.is_valid_yes_no?(has_persistent_cookies)
            BD.set(session_id, 'hasPersistentCookies', has_persistent_cookies)
          else
            self.err_msg "Invalid value for hasPersistentCookies returned from the hook browser's initial connection."
          end

          # log a few info of newly hooked zombie in the console
          print_info "New Hooked Browser [id:#{zombie.id}, ip:#{zombie.ip}, type:#{browser_name}-#{browser_version}, os:#{os_name}], hooked domain [#{log_zombie_domain}:#{log_zombie_port.to_s}]"


          # Call autorun modules
          if config.get('beef.autorun.enable')
            autorun = []
            BeEF::Core::Configuration.instance.get('beef.module').each { |k, v|
              if v.has_key?('autorun') and v['autorun'] == true
                target_status = BeEF::Module.support(k, {'browser' => browser_name, 'ver' => browser_version, 'os' => os_name})
                if target_status == BeEF::Core::Constants::CommandModule::VERIFIED_WORKING
                  BeEF::Module.execute(k, session_id)
                  autorun.push(k)
                elsif target_status == BeEF::Core::Constants::CommandModule::VERIFIED_USER_NOTIFY and config.get('beef.autorun.allow_user_notify')
                  BeEF::Module.execute(k, session_id)
                  autorun.push(k)
                else
                  print_debug "Autorun attempted to execute unsupported module '#{k}' against Hooked browser [id:#{zombie.id}, ip:#{zombie.ip}, type:#{browser_name}-#{browser_version}, os:#{os_name}]"
                end
              end
            }
            if autorun.length > 0
              print_info "Autorun executed[#{autorun.join(', ')}] against Hooked browser [id:#{zombie.id}, ip:#{zombie.ip}, type:#{browser_name}-#{browser_version}, os:#{os_name}]"
            end
          end
        end

        def get_param(query, key)
          (query.class == Hash and query.has_key?(key)) ? query[key] : nil
        end
      end


    end
  end
end

