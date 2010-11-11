module BeEF
module Models

class User
  
  include DataMapper::Resource
  
  storage_names[:default] = 'users'
  
  property :id, Serial
  property :session_id, Text
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