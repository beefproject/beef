#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module AdminUI
module API
  
  module CommandExtension
    
    extend BeEF::API::Command
    
    include BeEF::Core::Constants::Browsers
    include BeEF::Core::Constants::CommandModule
    
    #
    # Get the browser detail from the database.
    #
    def get_browser_detail(key)
      bd = BeEF::Core::Models::BrowserDetails
      (print_error "@session_id is invalid";return) if not BeEF::Filters.is_valid_hook_session_id?(@session_id)
      bd.get(@session_id, key)
    end
  end
  
end
end
end
end
