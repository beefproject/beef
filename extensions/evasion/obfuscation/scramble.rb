#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Evasion
      class Scramble
        include Singleton

        def need_bootstrap
          false
        end

        def execute(input, config)
          @output = input

          to_scramble = config.get('beef.extension.evasion.scramble')
          to_scramble.each do |var, value|
             if var == value
               # Variables have not been scrambled yet
               mod_var = BeEF::Extension::Evasion::Helper::random_string(3)
               @output.gsub!(var,mod_var)
               config.set("beef.extension.evasion.scramble.#{var}",mod_var)
               print_debug "[OBFUSCATION - SCRAMBLER] string [#{var}] scrambled -> [#{mod_var}]"
             else
               # Variables already scrambled, re-use the one already created to maintain consistency
               @output.gsub!(var,value)
               print_debug "[OBFUSCATION - SCRAMBLER] string [#{var}] scrambled -> [#{value}]"
             end
             @output
          end

          if config.get('beef.extension.evasion.scramble_cookies')
            # ideally this should not be static, but it's static in JS code, so fine for nowend
            mod_cookie = BeEF::Extension::Evasion::Helper::random_string(5)
            if config.get('beef.http.hook_session_name') == "BEEFHOOK"
              @output.gsub!("BEEFHOOK",mod_cookie)
              config.set('beef.http.hook_session_name',mod_cookie)
              print_debug "[OBFUSCATION - SCRAMBLER] cookie [BEEFHOOK] scrambled -> [#{mod_cookie}]"
            else
              @output.gsub!("BEEFHOOK",config.get('beef.http.hook_session_name'))
              print_debug "[OBFUSCATION - SCRAMBLER] cookie [BEEFHOOK] scrambled -> [#{config.get('beef.http.hook_session_name')}]"
            end
          end

          @output
        end
      end
    end
  end
end

