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

        def random_string(length=5)
          chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ'
          result = ''
          length.times { result << chars[rand(chars.size)] }
          result
        end

        def execute(input, config)
          to_scramble = config.get('beef.extension.evasion.to_scramble')
          to_scramble.each do |var|
             mod_var = random_string
             input = input.gsub!(var,random_string)
             print_debug "[OBFUSCATION - SCRAMBLER] string [#{var}] scrambled -> [#{mod_var}]"

             #todo: add scrambled vars to an Hash.
             #todo: even better. Add them to the Configuration object, like "beef" => "cnjD3"
             #@@to_scramble = config.get('beef.http.evasion.scramble_variables')
             #@@scrambled = Hash.new
          end
           input
        end

      end
    end
  end
end

