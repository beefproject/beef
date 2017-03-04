#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Handlers

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