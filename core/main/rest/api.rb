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
  module Core
    module Rest

      module RegisterHooksHandler
        def self.mount_handler(server)
          server.mount('/api/hooks', BeEF::Core::Rest::HookedBrowsers.new)
        end
      end

      module RegisterModulesHandler
        def self.mount_handler(server)
          server.mount('/api/modules', BeEF::Core::Rest::Modules.new)
        end
      end

      module RegisterCategoriesHandler
        def self.mount_handler(server)
          server.mount('/api/categories', BeEF::Core::Rest::Categories.new)
        end
      end

      module RegisterLogsHandler
        def self.mount_handler(server)
          server.mount('/api/logs', BeEF::Core::Rest::Logs.new)
        end
      end

      module RegisterAdminHandler
        def self.mount_handler(server)
          server.mount('/api/admin', BeEF::Core::Rest::Admin.new)
        end
      end

      BeEF::API::Registrar.instance.register(BeEF::Core::Rest::RegisterHooksHandler, BeEF::API::Server, 'mount_handler')
      BeEF::API::Registrar.instance.register(BeEF::Core::Rest::RegisterModulesHandler, BeEF::API::Server, 'mount_handler')
      BeEF::API::Registrar.instance.register(BeEF::Core::Rest::RegisterCategoriesHandler, BeEF::API::Server, 'mount_handler')

      BeEF::API::Registrar.instance.register(BeEF::Core::Rest::RegisterLogsHandler, BeEF::API::Server, 'mount_handler')
      BeEF::API::Registrar.instance.register(BeEF::Core::Rest::RegisterAdminHandler, BeEF::API::Server, 'mount_handler')

      #
      # Check the source IP is within the permitted subnet
      # This is from extensions/admin_ui/controllers/authentication/authentication.rb
      #
      def self.permitted_source?(ip)
        # get permitted subnet 
        permitted_ui_subnet = BeEF::Core::Configuration.instance.get("beef.restrictions.permitted_ui_subnet")
        target_network = IPAddr.new(permitted_ui_subnet)
        
        # test if ip within subnet
        return target_network.include?(ip)
      end

    end
  end
end
