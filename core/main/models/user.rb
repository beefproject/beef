module BeEF
module Core
module Models
  #
  # Table stores the list of users that have authenticated into beef.
  #
  # TODO: move this table into the AdminUI extension folder.
  #
  class User
  
    include DataMapper::Resource
  
    storage_names[:default] = 'extension.admin_ui.users'
    
    property :id, Serial
    property :session_id, String, :length => 255
    property :ip, Text
  
    #
    # Checks if the user has been authenticated
    #
    def authenticated?
      true || false if not @ip.nil?
    end
  
  end

end
end
end