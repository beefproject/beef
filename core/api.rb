#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
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
module API

    #
    # Calls a API fire against a certain class / module (c) method (m) with n parameters (*args)
    #
    def self.fire(c, m, *args)
        mods = c.extended_in_modules
        if mods.length > 0
            if self.verify_api_path(c, m) and c.ancestors[0].to_s > "BeEF::API"
                method = self.get_api_path(c, m)
                mods.each do |mod|
                  begin
                    #Only used for API Development
                    #print_info "API: #{mod} fired #{method}"
                    mod.send method, *args
                  rescue Exception => e
                    print_error "API Fire Error: #{e.message} in #{mod.to_s}.#{method.to_s}()"
                  end
                end
            else
                print_error "API Path not defined for Class: "+c.to_s+" Method: "+m.to_s
            end
        end
    end

    # Verifies that the api_path has been regitered
    def self.verify_api_path(c, m)
        return (c.const_defined?('API_PATHS') and c.const_get('API_PATHS').has_key?(m))
    end

    # Gets the sym set to the api_path
    def self.get_api_path(c, m)
        return (self.verify_api_path(c, m)) ? c.const_get('API_PATHS')[m] : nil;
    end
   
end
end

require 'core/api/module'
require 'core/api/extension'
require 'core/api/extensions'
require 'core/api/main/migration'
require 'core/api/main/network_stack/assethandler.rb'
require 'core/api/main/server/handler'
require 'core/api/main/server/hook'
require 'core/api/main/configuration'

