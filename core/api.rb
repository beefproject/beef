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

    # Registra class to handle all registered timed API calls
    class Registra

        include Singleton

        def initialize
            @registry = []
            @count = 1
        end

        # Register owner, c, method and matching params
        def register(owner, c, method, params = [])
            if self.verify_api_path(c, method)
                if not self.registered?(owner, c, method, params)
                    id = @count
                    @registry << {
                        'id' => id,
                        'owner' => owner,
                        'class' => c,
                        'method' => method,
                        'params' => params
                    }
                    @count += 1
                    return id
                else
                    print_debug "API Registra: Attempting to re-register API call #{c.to_s} :#{method.to_s}"
                end
            else
                print_error "API Registra: Attempted to register non-existant API method #{c.to_s} :#{method.to_s}"
            end
        end
        
        # returns boolean whether or not any owner has registered
        def registered?(owner, c, method, params = [])
            @registry.each{|r|
                if r['owner'] == owner and r['class'] == c and r['method'] == method and params == r['params']
                    return true
                end
            }
            return false
        end

        # match is used to determine if a fire() method should continue, matchs a registered API hook without the owner
        def matched?(c, method, params = [])
            @registry.each{|r|
                if r['class'] == c and r['method'] == method and self.is_matched_params?(r, params)
                    return true
                end
            }
            return false
        end

        # unregister API call from owner, class and method
        def unregister(id)
            @registry.delete_if{|r|
                r['id'] == id
            }
        end

        # gets all owners registered to an API call
        def get_owners(c, method, params = [])
            owners = []
            @registry.each{|r|
                if r['class'] == c and r['method'] == method
                    if self.is_matched_params?(r, params)
                        owners << { :owner => r['owner'], :id => r['id']}
                    end
                end
            }
            return owners
        end

        # Verifies that the api_path has been regitered
        def verify_api_path(c, m)
            return (c.const_defined?('API_PATHS') and c.const_get('API_PATHS').has_key?(m))
        end

        # Gets the sym set to the api_path
        def get_api_path(c, m)
            return (self.verify_api_path(c, m)) ? c.const_get('API_PATHS')[m] : nil;
        end

        # Match stored API parameters to params, if array item is nil then skip this item
        def is_matched_params?(reg, params)
           stored = reg['params']
           if stored.length == params.length
                matched = true
                stored.each_index{|i|
                    next if stored[i] == nil
                    if not stored[i] == params[i]
                        matched = false
                    end
                }
                return false if not matched
           end
            # We return a match because the fire() method did not indicate any, or 
            # we return a match because there were no params defined for this register
            return true
        end

        #
        # Calls a API fire against a certain class / module (c) method (m) with n parameters (*args)
        #
        def fire(c, m, *args)
            mods = self.get_owners(c, m, args)
            if mods.length > 0
                data = []
                if self.verify_api_path(c, m) and c.ancestors[0].to_s > "BeEF::API"
                    method = self.get_api_path(c, m)
                    mods.each do |mod|
                      begin
                        #Only used for API Development
                        #print_info "API: #{mod} fired #{method}"
                        result = mod[:owner].method(method).call(*args)
                        if not result == nil
                            data << {:api_id => mod[:id], :data => result}
                        end
                      rescue Exception => e
                        print_error "API Fire Error: #{e.message} in #{mod.to_s}.#{method.to_s}()"
                      end
                    end
                else
                    print_error "API Path not defined for Class: "+c.to_s+" Method: "+m.to_s
                end
                return data
            end
            return nil
        end

    end
   
end
end

require 'core/api/module'
require 'core/api/modules'
require 'core/api/extension'
require 'core/api/extensions'
require 'core/api/main/migration'
require 'core/api/main/network_stack/assethandler.rb'
require 'core/api/main/server'
require 'core/api/main/server/hook'
require 'core/api/main/configuration'

