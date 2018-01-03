#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Evasion
      require 'uglifier'
      class Minify
        include Singleton

        def need_bootstrap
          false
        end

        def execute(input, config)
          begin 
            input2 = Uglifier.compile(input)
            print_debug "[OBFUSCATION - MINIFIER] Javascript has been minified"
            input2
          rescue
            print_error "[OBFUSCATION - MINIFIER FAILED] Javascript couldn't be minified. Returning the input form."
            input
          end
        end
      end
    end
  end
end

