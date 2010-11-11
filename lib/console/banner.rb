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
      hook_uri  = "http://#{beef_host}:"
      hook_uri += "#{@configuration.get("http_port")}"
      hook_uri += "#{@configuration.get("hook_file")}"

      ui_uri  = "http://#{beef_host}:"
      ui_uri += "#{@configuration.get("http_port")}"
      ui_uri += "#{@configuration.get("http_panel_path")}"
      
      demo_uri  = "http://#{beef_host}:"
      demo_uri += "#{@configuration.get("http_port")}"
      demo_uri += "#{@configuration.get("http_demo_path")}"
      
      detail_tab = ' ' * 1 + '--[ '

      puts 
      puts " -=[ BeEF " + "v#{version} ]=-\n\n"
      puts detail_tab + "Modules:   #{BeEF::Models::CommandModule.all.length}"
      puts detail_tab + "Hook URL:  #{hook_uri}"
      puts detail_tab + "UI URL:    #{ui_uri}"
      puts detail_tab + "Demo URL:  #{demo_uri}"
      puts

    end
  end

end
end
