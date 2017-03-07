#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Handlers

      # This Singleton is responsible to handle dynamic internal routes via URLMap.
      # when the hooked browser sends data to the DyanamicHandler, the data is sent
      # to the appropriate internal handler. Internal Handlers are used via the MOUNTS
      # constant in /core/main/network_stack/handlers/dynamicreconstruction.rb
      #
      # Since command modules are dynamic, this class dynamically mounts specific command
      # module handlers whenever a new command is sent to the hooked browser.
      class Dyncommands

        include Singleton

        def initialize
          @routes = {}
          @url_map = Rack::URLMap.new
        end

        def call(env)
          @url_map.call(env)
        end

        def register_route(path, &block)
          print_debug "ADDED ROUTE with path: #{path}\n block: #{block}"
          @routes[path] = block
          @url_map.remap(@routes)
        end
      end
    end
  end
end