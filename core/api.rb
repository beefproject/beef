=begin

  

=end
module BeEF
module API

    #
    # Calls a API fire against a certain class / module (c) method (m) with n parameters (*args)
    #
    def self.fire(c, m, *args)
        c.extended_in_modules.each do |mod|
          begin
            mod.send m.to_sym, *args
          rescue Exception => e
            puts e.message  
            puts e.backtrace
          end
        end
    end
   
end
end

require 'core/api/command'
require 'core/api/extension'
require 'core/api/migration'
require 'core/api/server/handler'
require 'core/api/server/hook'
