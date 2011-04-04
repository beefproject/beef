module BeEF
module Console

  module Banner
    #
    # Generates banner
    #
    def self.generate

      # set the pre-string for output
      detail_tab = ' ' * 1 + '--[ '
      
      # get the configuration information
      @configuration = BeEF::Configuration.instance
      version = BeEF::Configuration.instance.get('beef_version')
      beef_host = @configuration.get("http_public") || @configuration.get("http_host") 
      
      # create an array of the interfaces the framework is listening on
      if beef_host == '0.0.0.0' # the framework will listen on all interfaces 
        interfaces = Socket.getaddrinfo(Socket.gethostname, 0, Socket::AF_UNSPEC, Socket::SOCK_STREAM, nil, Socket::AI_CANONNAME).map { |x| x[3] }
        interfaces = interfaces << "127.0.0.1"
        interfaces.uniq!
      else # the framework will listen on only one interface
        interfaces = [beef_host]
      end

      # output the banner to the console
      puts 
      puts " -=[ BeEF v#{version} ]=-\n\n"
      puts detail_tab + "Modules:   #{BeEF::Models::CommandModule.all.length}" # output the number of modules available
      interfaces.map do |host| # display the important URLs on each interface from the interfaces array
        puts detail_tab
        puts detail_tab + "Hook URL:  http://#{host}:#{@configuration.get("http_port")}#{@configuration.get("hook_file")}"
        puts detail_tab + "UI URL:    http://#{host}:#{@configuration.get("http_port")}#{@configuration.get("http_panel_path")}"
        puts detail_tab + "Demo URL:  http://#{host}:#{@configuration.get("http_port")}#{@configuration.get("http_demo_path")}"
      end
 
       # if the proxy is enabled output the address
      if (@configuration.get('http_proxy_enable').to_i > 0)
        puts
        puts detail_tab + "HTTP Proxy: http://#{@configuration.get("http_proxy_bind_address")}:#{@configuration.get("http_proxy_bind_port")}"
      end
  
      puts
      puts "Ensure you are running the latest framework version. Run 'svn update' to update"
      puts

    end
  end

end
end
