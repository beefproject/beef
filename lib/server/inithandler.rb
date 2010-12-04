module BeEF
  
  #
  # The http handler that manages the return of the initial browser details.
  #
  class InitHandler < WEBrick::HTTPServlet::AbstractServlet
    
    attr_reader :guard
    
    HB = BeEF::Models::Zombie
    BD = BeEF::Models::BrowserDetails
    
    #
    # Class constructor
    #
    def initialize(config)
      # we set up a mutex
      @guard = Mutex.new
    end
    
    #
    # This function receives any POST http requests. We only
    # allow the hooked browser to send back results using POST.
    #
    def do_POST(request, response)
      
      # validate hook session value
      session_id = request.query['BEEFHOOK'] || nil
      raise WEBrick::HTTPStatus::BadRequest, "session id is invalid" if not Filter.is_valid_hook_session_id?(session_id)
      hooked_browser = HB.first(:session => session_id, :has_init => false)
      raise WEBrick::HTTPStatus::BadRequest, "Invalid beef session id: the hooked browser cannot be found in the database" if hooked_browser.nil?
      
      # get and store browser name
      browser_name = get_param(request.query, 'BrowserName')
      raise WEBrick::HTTPStatus::BadRequest, "Invalid browser name" if not Filter.is_valid_browsername?(browser_name)
      BD.set(session_id, 'BrowserName', browser_name)

      # get and store browser version
      browser_version = get_param(request.query, 'BrowserVersion')
      raise WEBrick::HTTPStatus::BadRequest, "Invalid browser version" if not Filter.is_valid_browserversion?(browser_version)
      BD.set(session_id, 'BrowserVersion', browser_version)

      # get and store browser string
      browser_string = get_param(request.query, 'BrowserReportedName')
      raise WEBrick::HTTPStatus::BadRequest, "Invalid browser browser string" if not Filter.is_valid_browserstring?(browser_string)
      BD.set(session_id, 'BrowserReportedName', browser_string)
      
      # get and store the os name
      os_name = get_param(request.query, 'OsName')
      raise WEBrick::HTTPStatus::BadRequest, "Invalid browser os name" if not Filter.is_valid_osname?(os_name)
      BD.set(session_id, 'OsName', os_name)
      
      # get and store page title
      page_title = get_param(request.query, 'PageTitle')
      raise WEBrick::HTTPStatus::BadRequest, "Invalid page title name" if not Filter.is_valid_pagetitle?(page_title)
      BD.set(session_id, 'PageTitle', page_title)
      
      # get and store page title
      host_name = get_param(request.query, 'HostName')
      raise WEBrick::HTTPStatus::BadRequest, "Invalid host name" if not Filter.is_valid_hostname?(host_name)
      BD.set(session_id, 'HostName', host_name)
      
      # get and store the browser plugins
      browser_plugins = get_param(request.query, 'BrowserPlugins')
      if not browser_plugins.nil?
        #TODO: add filters
        #raise WEBrick::HTTPStatus::BadRequest, "Invalid browser plugins: has non printable chars" if not Filter.has_non_printable_char?(browser_plugins)
        #raise WEBrick::HTTPStatus::BadRequest, "Invalid browser plugins: has null chars" if not Filter.has_null?(browser_plugins)
        BD.set(session_id, 'BrowserPlugins', browser_plugins)
      end
      
      # get and store the internal ip address
      internal_ip = get_param(request.query, 'InternalIP')
      if not internal_ip.nil?
        #TODO: add Filter
        BD.set(session_id, 'InternalIP', internal_ip)
      end
      
      # get and store the internal hostname
      internal_hostname = get_param(request.query, 'InternalHostname')
      if not internal_hostname.nil?
        raise WEBrick::HTTPStatus::BadRequest, "Invalid internal host name" if not Filter.is_valid_hostname?(host_name)
        BD.set(session_id, 'InternalHostname', internal_hostname)
      end
      
      # init details have been returned so set flag and save
      hooked_browser.has_init = true
      @guard.synchronize {      
        hooked_browser.save
      }
    
      response.body = ''
    end
    
    # returns a selected parameter from the query string.
    def get_param(query, key)
      return nil if query[key].nil?
      
      b64_param = query[key]
      raise WEBrick::HTTPStatus::BadRequest, "Invalid init base64 value" if Filter.has_non_printable_char?(b64_param)
      escaped_param = CGI.unescapeHTML(b64_param)
      raise WEBrick::HTTPStatus::BadRequest, "Invalid init escaped value" if Filter.has_non_printable_char?(escaped_param)        
      param = Base64.decode64(escaped_param)
      raise WEBrick::HTTPStatus::BadRequest, "Invalid init value" if Filter.has_valid_browser_details_chars?(param)
      param
    end
    
  end
  
end