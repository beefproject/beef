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

      # create the structure repesenting the hooked browser
      zombie = BeEF::Core::Models::HookedBrowser.new(:ip => @data['request'].peeraddr[3], :session => session_id)
      zombie.firstseen = Time.new.to_i
      zombie.httpheaders = @data['request'].header.to_json

      zombie.save # the save needs to be conducted before any hooked browser specific logging
      
      # add a log entry for the newly hooked browser
      log_zombie_domain = zombie.domain
      log_zombie_domain = "(blank)" if log_zombie_domain.nil? or log_zombie_domain.empty?
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
    end
   
    def get_param(query, key)
      return (query.class == Hash and query.has_key?(key)) ? query[key] : nil
    end
    
  end
  
end
end
end