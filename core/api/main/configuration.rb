#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module API
  module Configuration 
    
    # @note Defined API Paths
    API_PATHS = {
        'module_configuration_load' => :module_configuration_load
    }
    
    # Fires just after module configuration is loaded and merged
    # @param [String] mod module key
    def module_configuration_load(mod); end

  end
  
end
end
