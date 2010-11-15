module BeEF
module Console

  module Banner
    #
    # Generates banner
    #
    def self.generate
      @configuration = BeEF::Configuration.instance

      version = BeEF::Configuration.instance.get('beef_version')

      beef_host = @configuration.get("http_public") || @configuration.get("http_host") 
      
      if beef_host == '0.0.0.0'
        zcs_hosts = Socket.getaddrinfo(Socket.gethostname, 'www', Socket::AF_INET, Socket::SOCK_STREAM).map { |x| x[3] }
        zcs_hosts = zcs_hosts << "127.0.0.1"
      else
        zcs_hosts = [beef_host]
      end
      
      detail_tab = ' ' * 1 + '--[ '

      puts 
      puts " -=[ BeEF " + "v#{version} ]=-\n\n"
      puts detail_tab + "Modules:   #{BeEF::Models::CommandModule.all.length}"
      
      zcs_hosts.map do |host|
        puts detail_tab
        puts detail_tab + "Hook URL:  http://#{host}:#{@configuration.get("http_port")}#{@configuration.get("hook_file")}"
        puts detail_tab + "UI URL:    http://#{host}:#{@configuration.get("http_port")}#{@configuration.get("http_panel_path")}"
        puts detail_tab + "Demo URL:  http://#{host}:#{@configuration.get("http_port")}#{@configuration.get("http_demo_path")}"
      end
 
      puts

    end
  end

end
end
