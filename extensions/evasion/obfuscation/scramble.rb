#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
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
          @output
        end
      end
    end
  end
end

