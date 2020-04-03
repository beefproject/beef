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
              print("beefnew")
            else
              legacy_build_beefjs!(req_host)
            end
          end

          # Finds the path to js components
          # @param [String] component Name of component
          # @return [String|Boolean] Returns false if path was not found, otherwise returns component path
          def find_beefjs_component_path(component)
            if config.get("beef.testif.enable")
              print("beefnew")
            else
              legacy_find_beefjs_component_path(component)
            end
          end

          # Builds missing beefjs components.
          # @param [Array] beefjs_components An array of component names
          def build_missing_beefjs_components(beefjs_components)
            if config.get("beef.testif.enable")
              print("beefnew")
            else
              build_missing_beefjs_components(beefjs_components)
            end
          end
        end
      end
    end
  end
end
