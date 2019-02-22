#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Evasion
      require 'uglifier'
      class Minify
        include Singleton

        def need_bootstrap?
          false
        end

        def execute(input, config)
          opts = {
            :output => {
              :comments => :none
            },
            :compress => {
              :dead_code => true,
              :drop_console => (config.get('beef.client_debug') ? false : true)
            }
          }
          output = Uglifier.compile(input, opts)
          print_debug "[OBFUSCATION - Minifier] JavaScript has been minified"
          output
        rescue => e
          print_error "[OBFUSCATION - Minifier] JavaScript couldn't be minified: #{e.messsage}"
          input
        end
      end
    end
  end
end

