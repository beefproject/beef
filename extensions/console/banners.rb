module BeEF
module Extension
module Console

module Banners
  class << self
    attr_accessor :interfaces
  
    #
    # Prints BeEF's welcome message
    #
    def print_welcome_msg
	config = BeEF::Core::Configuration.instance
	version = config.get('beef.version')
        print_info " -=[ BeEF v#{version} ]=-"
        print_info "Ensure you're running the latest framework version. Run 'svn update' to update."
    end

    #
    # Prints the number of network interfaces beef is operating on.
    # Looks like that:
    #
    # [14:06:48][*] 5 network interfaces were detected.
    #
    def print_network_interfaces_count
      # get the configuration information
      configuration = BeEF::Core::Configuration.instance
      version = BeEF::Core::Configuration.instance.get('beef.version')
      beef_host = configuration.get("beef.http.public") || configuration.get("beef.http.host") 
    
      # create an array of the interfaces the framework is listening on
      if beef_host == '0.0.0.0' # the framework will listen on all interfaces 
        interfaces = Socket.getaddrinfo(Socket.gethostname, 0, Socket::AF_UNSPEC, Socket::SOCK_STREAM, nil, Socket::AI_CANONNAME).map { |x| x[3] }
        interfaces = interfaces << "127.0.0.1"
        interfaces.uniq!
      else # the framework will listen on only one interface
        interfaces = [beef_host]
      end
    
      self.interfaces = interfaces
    
      # output the banner to the console
      print_info "#{interfaces.count} network interfaces were detected."
    end
    
    #
    # Prints the route to the network interfaces beef has been deployed on.
    # Looks like that:
    #
    # [14:06:48][+] running on network interface: 192.168.255.1
    # [14:06:48]    |   Hook URL: http://192.168.255.1:3000/hook.js
    # [14:06:48]    |   UI URL:   http://192.168.255.1:3000/ui/panel
    # [14:06:48]    |_  Demo URL: http://192.168.255.1:3000/demos/basic.html
    # [14:06:48][+] running on network interface: 127.0.0.1
    # [14:06:48]    |   Hook URL: http://127.0.0.1:3000/hook.js
    # [14:06:48]    |   UI URL:   http://127.0.0.1:3000/ui/panel
    # [14:06:48]    |_  Demo URL: http://127.0.0.1:3000/demos/basic.html
    #
    def print_network_interfaces_routes
      configuration = BeEF::Core::Configuration.instance
      
      self.interfaces.map do |host| # display the important URLs on each interface from the interfaces array
        print_success "running on network interface: #{host}"
        data = "Hook URL: http://#{host}:#{configuration.get("beef.http.port")}#{configuration.get("beef.http.hook_file")}\n"
        data += "UI URL:   http://#{host}:#{configuration.get("beef.http.port")}#{configuration.get("beef.http.panel_path")}\n"
        data += "Demo URL: http://#{host}:#{configuration.get("beef.http.port")}#{configuration.get("beef.http.demo_path")}"
        
        print_more data
      end
    end
    
    #
    # Print loaded extensions
    #
    def print_loaded_extensions
      extensions = BeEF::API::Extension.extended_in_modules
      print_info "#{extensions.size} extensions loaded:"
      output = ''
      
      extensions.each do |extension|
        if extension.full_name
          output += "#{extension.full_name}\n"
        end
      end
      
      print_more output
    end
    
    #
    # Print loaded modules
    # TODO: This should display the count of modules like the extensions function, however this is blocked on issue 319
    def print_loaded_modules
        print_info "modules loaded."
    end
  end
end

end
end
end
