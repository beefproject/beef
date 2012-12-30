#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module API
module Server
  module Hook 

    # @note Defined API Paths
    API_PATHS = {
        'pre_hook_send' => :pre_hook_send
    }
    
    # Fires just before the hook is sent to the hooked browser
    # @param [Class] handler the associated handler Class
    def pre_hook_send(handler); end
    
  end
  
end
end
end
