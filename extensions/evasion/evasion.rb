#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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

          def add_bootstrapper
            @bootstrap = ''
             # add stuff at the end, only once (when serving the initial init javascript)
            @@techniques.each do |technique|
              #1. get the ruby module inside the obfuscation directory: the file name will be the same of the string used in "chain"
              #2. call the "execute" method of the ruby module, passing the input
              #3. update the input in order that next technique will work on the pre-processed input.
              if File.exists?("#{$root_dir}/extensions/evasion/obfuscation/#{technique}.rb")
                klass = BeEF::Extension::Evasion.const_get(technique.capitalize).instance
                is_bootstrap_needed = klass.need_bootstrap
                if is_bootstrap_needed
                  print_debug "[OBFUSCATION] Adding bootstrapper for technique [#{technique}]"
                  @bootstrap += klass.get_bootstrap
                end
              end
              @bootstrap
            end
            @bootstrap
          end

          def apply_chain(input, techniques)
            @output = input
            techniques.each do |technique|
               #1. get the ruby module inside the obfuscation directory: the file name will be the same of the string used in "chain"
               #2. call the "execute" method of the ruby module, passing the input
               #3. update the input in order that next technique will work on the pre-processed input.
               if File.exists?("#{$root_dir}/extensions/evasion/obfuscation/#{technique}.rb")
                  print_debug "[OBFUSCATION] Applying technique [#{technique}]"
                  klass = BeEF::Extension::Evasion.const_get(technique.capitalize).instance
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

