#
# Copyright (c) 2006-2020 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module AdminUI
module API

  #
  # We use this module to register all the http handler for the Administrator UI
  #
  module Handler
    require 'uglifier'

    BeEF::API::Registrar.instance.register(BeEF::Extension::AdminUI::API::Handler, BeEF::API::Server, 'mount_handler')

    def self.evaluate_and_minify(content, params, name)
      erubis = Erubis::FastEruby.new(content)
      evaluated = erubis.evaluate(params)

      print_debug "[AdminUI] Minifying #{name} (#{evaluated.size} bytes)"
      begin
        opts = {
          :output => {
            :comments => :none
          },
          :compress => {
            :dead_code => true,
          }
        }
        minified = Uglifier.compile(evaluated, opts)
        print_debug "[AdminUI] Minified #{name} (#{minified.size} bytes)"
      rescue
        print_error "[AdminUI] Error: Could not minify JavaScript file: #{name}"
        print_more "[AdminUI] Ensure nodejs is installed and `node' is in `$PATH` !"
        minified = evaluated
      end
      write_to = File.new("#{File.dirname(__FILE__)}/../media/javascript-min/#{name}.js", "w+")
      File.open(write_to, 'w') { |file| file.write(minified) }

      File.path write_to
    rescue => e
      print_error "[AdminUI] Error: #{e.message}"
      print_error e.backtrace
    end

    def self.build_javascript_ui(beef_server)
      #NOTE: order counts! make sure you know what you're doing if you add files
      esapi = %w(
      esapi/Class.create.js
      esapi/jquery-3.3.1.min.js
      esapi/jquery-encoder-0.1.0.js)

      ux = %w(
      ui/common/beef_common.js
      ux/PagingStore.js
      ux/StatusBar.js
      ux/TabCloseMenu.js)

      panel = %w(
      ui/panel/common.js
      ui/panel/PanelStatusBar.js
      ui/panel/tabs/ZombieTabDetails.js
      ui/panel/tabs/ZombieTabLogs.js
      ui/panel/tabs/ZombieTabCommands.js
      ui/panel/tabs/ZombieTabRider.js
      ui/panel/tabs/ZombieTabXssRays.js
      wterm/wterm.jquery.js
      ui/panel/tabs/ZombieTabIpec.js
      ui/panel/tabs/ZombieTabAutorun.js
      ui/panel/PanelViewer.js
      ui/panel/LogsDataGrid.js
      ui/panel/BrowserDetailsDataGrid.js
      ui/panel/ZombieDataGrid.js
      ui/panel/MainPanel.js
      ui/panel/ZombieTab.js
      ui/panel/ZombieTabs.js
      ui/panel/zombiesTreeList.js
      ui/panel/ZombiesMgr.js
      ui/panel/tabs/ZombieTabNetwork.js
      ui/panel/tabs/ZombieTabRTC.js
      ui/panel/Logout.js
      ui/panel/WelcomeTab.js
      ui/panel/ModuleSearching.js)

      global_js = esapi + ux + panel

      js_files = ''
      global_js.each do |file|
        js_files << File.read(File.dirname(__FILE__)+'/../media/javascript/'+file) + "\n\n"
      end

      config = BeEF::Core::Configuration.instance
      bp = config.get "beef.extension.admin_ui.base_path"

      # if more dynamic variables are needed in JavaScript files
      # add them here in the following Hash
      params = {
       'base_path' => bp
      }

      # process all JavaScript files, evaluating them with Erubis
      print_debug "[AdminUI] Initializing admin panel ..."
      web_ui_all = self.evaluate_and_minify(js_files, params, 'web_ui_all')
      auth_js_file = File.read(File.dirname(__FILE__)+'/../media/javascript/ui/authentication.js') + "\n\n"
      web_ui_auth = self.evaluate_and_minify(auth_js_file, params, 'web_ui_auth')

      beef_server.mount("#{bp}/web_ui_all.js", Rack::File.new(web_ui_all))
      beef_server.mount("#{bp}/web_ui_auth.js", Rack::File.new(web_ui_auth))
    end

    #
    # This function gets called automatically by the server.
    #
    def self.mount_handler(beef_server)
      config = BeEF::Core::Configuration.instance

      # Web UI base path, like http://beef_domain/<bp>/panel
      bp = config.get "beef.extension.admin_ui.base_path"

      # registers the http controllers used by BeEF core (authentication, logs, modules and panel)
      Dir["#{$root_dir}/extensions/admin_ui/controllers/**/*.rb"].each do |http_module|
        require http_module
        mod_name = File.basename http_module, '.rb'
        beef_server.mount("#{bp}/#{mod_name}", BeEF::Extension::AdminUI::Handlers::UI.new(mod_name))
      end

      # mount the folder were we store static files (javascript, css, images, audio) for the admin ui
      media_dir = File.dirname(__FILE__)+'/../media/'
      beef_server.mount("#{bp}/media", Rack::File.new(media_dir))

      # If we're not imitating a web server, mount the favicon to /favicon.ico
      if !config.get("beef.http.web_server_imitation.enable")
        BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind(
          "/extensions/admin_ui/media/images/#{config.get("beef.extension.admin_ui.favicon_file_name")}",
          '/favicon.ico',
          'ico')
      end

      self.build_javascript_ui beef_server
    end
  end
end
end
end
end
