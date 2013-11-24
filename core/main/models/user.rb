#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models

  # @todo move this table into the AdminUI extension folder.
  class User
  
    include DataMapper::Resource
  
    storage_names[:default] = 'extension_adminui_users'
    
    property :id, Serial
    property :session_id, String, :length => 255
    property :ip, Text
  
    # Checks if the user has been authenticated
    # @return [Boolean] If the user is authenticated
    def authenticated?
      true || false if not @ip.nil?
    end
  
  end

end
end
end
