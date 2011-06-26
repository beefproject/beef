=begin

  

=end
module BeEF
module API

    #
    # Calls a API fire against a certain class / module (c) method (m) with n parameters (*args)
    #
    def self.fire(c, m, *args)
        if self.verify_api_path(c, m)
            method = self.get_api_path(c, m)
            c.extended_in_modules.each do |mod|
              begin
                mod.send method, *args
              rescue Exception => e
                print_error e.message  
              end
            end
        else
            print_error "API Path not defined for Class: "+c.to_s+" Method: "+m.to_s
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

require 'core/api/command'
require 'core/api/extension'
require 'core/api/migration'
require 'core/api/server/handler'
require 'core/api/server/hook'
