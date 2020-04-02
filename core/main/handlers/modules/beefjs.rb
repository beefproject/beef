#
# Copyright (c) 2006-2020 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Handlers
      module Modules

        # @note Purpose: avoid rewriting several times the same code.
        module BeEFJS

          include BeEF::Core::Handlers::Modules::legacyBeEFJS

          # Builds the default beefjs library (all default components of the library).
          # @param [Object] req_host The request object
          def build_beefjs!(req_host)
            if config.get("beef.testif.enable")

            else
              legacy_build_beefjs!(req_host)
            end
          end

          # Finds the path to js components
          # @param [String] component Name of component
          # @return [String|Boolean] Returns false if path was not found, otherwise returns component path
          def find_beefjs_component_path(component)
            component_path = component
            component_path.gsub!(/beef./, '')
            component_path.gsub!(/\./, '/')
            component_path.replace "#{$root_dir}/core/main/client/#{component_path}.js"

            return false if not File.exists? component_path

            component_path
          end

          # Builds missing beefjs components.
          # @param [Array] beefjs_components An array of component names
          def build_missing_beefjs_components(beefjs_components)
            # @note verifies that @beef_js_cmps is not nil to avoid bugs
            @beef_js_cmps = '' if @beef_js_cmps.nil?

            if beefjs_components.is_a? String
              beefjs_components_path = find_beefjs_component_path(beefjs_components)
              raise "Invalid component: could not build the beefjs file" if not beefjs_components_path
              beefjs_components = {beefjs_components => beefjs_components_path}
            end

            beefjs_components.keys.each { |k|
              next if @beef_js_cmps.include? beefjs_components[k]

              # @note path to the component
              component_path = beefjs_components[k]

              # @note we output the component to the hooked browser
              config = BeEF::Core::Configuration.instance
              if config.get("beef.extension.evasion.enable")
                evasion = BeEF::Extension::Evasion::Evasion.instance
                @body << evasion.obfuscate(File.read(component_path) + "\n\n")
              else
                @body << File.read(component_path) + "\n\n"
              end

              # @note finally we add the component to the list of components already generated so it does not get generated numerous times.
              if @beef_js_cmps.eql? ''
                @beef_js_cmps = component_path
              else
                @beef_js_cmps += ",#{component_path}"
              end
            }
          end
        end
      end
    end
  end
end
