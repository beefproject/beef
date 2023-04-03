#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
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

          def self.evaluate_and_minify(content, params)
            begin
              erubis = Erubis::FastEruby.new(content)
              evaluated = erubis.evaluate(params)
            rescue => e
              print_error("[Admin UI] Evaluating with Eruby failed: #{e.message}")
              return
            end

            print_debug "[AdminUI] Minifying JavaScript (#{evaluated.size} bytes)"

            opts = {
              output: {
                comments: :none
              },
              compress: {
                dead_code: true
              },
              harmony: true
            }

            begin
              minified = Uglifier.compile(evaluated, opts)
            rescue StandardError => e
              print_warning "[AdminUI] Error: Could not minify '#{name}' JavaScript file: #{e.message}"
              print_more "[AdminUI] Ensure nodejs is installed and `node' is in `$PATH` !"
              return evaluated
            end

            print_debug "[AdminUI] Minified #{evaluated.size} bytes to #{minified.size} bytes"

            return minified
          end

          def self.write_minified_js(name, content)
            temp_file = File.new("#{File.dirname(__FILE__)}/../media/javascript-min/#{File.basename(name)}", 'w+')
            File.write(temp_file, content)
          end

          def self.build_javascript_ui
            # NOTE: order counts! make sure you know what you're doing if you add files
            esapi = %w[
              esapi/Class.create.js
              esapi/jquery-3.3.1.min.js
              esapi/jquery-encoder-0.1.0.js
            ]

            ux = %w[
              ui/common/beef_common.js
              ux/PagingStore.js
              ux/StatusBar.js
              ux/TabCloseMenu.js
            ]

            panel = %w[
              ui/panel/common.js
              ui/panel/PanelStatusBar.js
              ui/panel/tabs/ZombieTabDetails.js
              ui/panel/tabs/ZombieTabLogs.js
              ui/panel/tabs/ZombieTabCommands.js
              ui/panel/tabs/ZombieTabRider.js
              ui/panel/tabs/ZombieTabXssRays.js
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
              ui/panel/ModuleSearching.js
            ]

            global_js = esapi + ux + panel

            admin_ui_js = ''
            global_js.each do |file_name|
              admin_ui_js << ("#{File.binread("#{File.dirname(__FILE__)}/../media/javascript/#{file_name}")}\n\n")
            end

            config = BeEF::Core::Configuration.instance
            bp = config.get 'beef.extension.admin_ui.base_path'

            # if more dynamic variables are needed in JavaScript files
            # add them here in the following Hash
            params = {
              'base_path' => bp
            }

            # process all JavaScript files, evaluating them with Erubis
            print_debug '[AdminUI] Initializing admin panel ...'

            web_ui_all = evaluate_and_minify(admin_ui_js, params)
            unless web_ui_all
              raise StandardError, "[AdminUI] evaluate_and_minify JavaScript failed: web_ui_all JavaScript is empty"
            end
            write_minified_js('web_ui_all.js', web_ui_all)

            auth_js_file = "#{File.binread("#{File.dirname(__FILE__)}/../media/javascript/ui/authentication.js")}\n\n"
            web_ui_auth = evaluate_and_minify(auth_js_file, params)
            unless web_ui_auth
              raise StandardError, "[AdminUI] evaluate_and_minify JavaScript failed: web_ui_auth JavaScript is empty"
            end
            write_minified_js('web_ui_auth.js', web_ui_auth)
          rescue => e
            raise StandardError, "Building Admin UI JavaScript failed: #{e.message}"
          end

          #
          # This function gets called automatically by the server.
          #
          def self.mount_handler(beef_server)
            config = BeEF::Core::Configuration.instance

            # Web UI base path, like http://beef_domain/<bp>/panel
            bp = config.get 'beef.extension.admin_ui.base_path'

            # registers the http controllers used by BeEF core (authentication, logs, modules and panel)
            Dir["#{$root_dir}/extensions/admin_ui/controllers/**/*.rb"].sort.each do |http_module|
              require http_module
              mod_name = File.basename http_module, '.rb'
              beef_server.mount("#{bp}/#{mod_name}", BeEF::Extension::AdminUI::Handlers::UI.new(mod_name))
            end

            # mount the media folder where we store static files (javascript, css, images, audio) for the admin ui
            media_dir = "#{File.dirname(__FILE__)}/../media/"
            beef_server.mount("#{bp}/media", Rack::File.new(media_dir))

            # If we're not imitating a web server, mount the favicon to /favicon.ico
            # NOTE: this appears to be broken
            unless config.get('beef.http.web_server_imitation.enable')
              BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind(
                "/extensions/admin_ui/media/images/#{config.get('beef.extension.admin_ui.favicon_file_name')}",
                '/favicon.ico',
                'ico'
              )
            end

            build_javascript_ui
          rescue => e
            print_error("[Admin UI] Could not mount URL route handlers: #{e.message}")
            print_more(e.backtrace)
            exit(1)
          end
        end
      end
    end
  end
end
