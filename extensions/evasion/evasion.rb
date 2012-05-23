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
        class Evasion
          include Singleton
          @@config = BeEF::Core::Configuration.instance
          @@techniques = @@config.get('beef.extension.evasion.chain')

          def initialize
          end

          # Obfuscate the input JS applying the chain of techniques defined in the main config file.
          def obfuscate(input)
            @input = apply_chain(input, @@techniques)
          end

          def inject_boostrapper(input)
             # add stuff at the end, only once (when serving the initial init javascript)
          end

          def apply_chain(input, techniques)
            @output = input
            techniques.each do |technique|
               #1. get the ruby module inside the obfuscation directory: the file name will be the same of the string used in "chain"
               #2. call the "execute" method of the ruby module, passing the input
               #3. update the input in order that next technique will work on the pre-processed input.
               if File.exists?("#{$root_dir}/extensions/evasion/obfuscation/#{technique}.rb")
                  print_debug "[OBFUSCATION] Applying technique [#{technique}]"
                  klass = BeEF::Extension::Evasion.const_get(technique.capitalize)
                  klass = klass.instance
                  @output = klass.execute(@output, @@config)
               end
              @output
            end
            @output
          end
        end
    end
  end
end

