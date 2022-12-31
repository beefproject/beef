#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Evasion
      class Evasion
        include Singleton

        @@config = BeEF::Core::Configuration.instance
        @@enabled = @@config.get('beef.extension.evasion.enable')

        def initialize
          return unless @@enabled

          @techniques ||= load_techniques

          if @techniques.empty?
            print_error '[Evasion] Initialization failed. No obfuscation techniques specified.'
            @@config.set('beef.extension.evasion.enable', false)
            return
          end

          print_debug "[Evasion] Loaded obfuscation chain: #{@techniques.join(', ')}"
        end

        # load obfuscation technique chain
        def load_techniques
          techniques = @@config.get('beef.extension.evasion.chain') || []
          return [] if techniques.empty?

          chain = []
          techniques.each do |technique|
            unless File.exist?("#{$root_dir}/extensions/evasion/obfuscation/#{technique}.rb")
              print_error "[Evasion] Failed to load obfuscation technique '#{technique}' - file does not exist"
              next
            end
            chain << technique
          end

          chain
        rescue StandardError => e
          print_error "[Evasion] Failed to load obfuscation technique chain: #{e.message}"
          []
        end

        # Obfuscate the input JS applying the chain of techniques defined in the main config file.
        def obfuscate(input)
          @input = apply_chain(input)
        end

        def add_bootstrapper
          bootstrap = ''
          # add stuff at the end, only once (when serving the initial init javascript)
          @techniques.each do |technique|
            # Call the "execute" method of the technique module, passing the input and update
            # the input in preperation for the next technique in the chain
            klass = BeEF::Extension::Evasion.const_get(technique.capitalize).instance
            if klass.need_bootstrap?
              print_debug "[Evasion] Adding bootstrapper for technique: #{technique}"
              bootstrap << klass.get_bootstrap
            end
          end

          bootstrap
        rescue StandardError => e
          print_error "[Evasion] Failed to bootstrap obfuscation technique: #{e.message}"
          print_error e.backtrace
        end

        def apply_chain(input)
          output = input
          @techniques.each do |technique|
            # Call the "execute" method of the technique module, passing the input and update
            # the input in preperation for the next technique in the chain
            print_debug "[Evasion] Applying technique: #{technique}"
            klass = BeEF::Extension::Evasion.const_get(technique.capitalize).instance
            output = klass.execute(output, @@config)
          end

          print_debug "[Evasion] Obfuscation completed (#{output.length} bytes)"
          output
        rescue StandardError => e
          print_error "[Evasion] Failed to apply obfuscation technique: #{e.message}"
          print_error e.backtrace
        end
      end
    end
  end
end
