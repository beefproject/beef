
module BeEF
module UI

#
# The session for BeEF UI.
#
class Session
  
  include Singleton
  
  attr_reader :ip, :id, :nonce, :auth_timestamp
    
  def initialize
    set_logged_out
    @auth_timestamp = Time.new
  end

  #
  # set the session logged in
  #
  def set_logged_in(ip)
    @id = BeEF::Crypto::secure_token
    @nonce = BeEF::Crypto::secure_token
    @ip = ip
  end
  
  #
  # set the session logged out
  #
  def set_logged_out
    @id = nil
    @nonce = nil
    @ip = nil
  end

  #
  # set teh auth_timestamp
  #
  def set_auth_timestamp(time)
    @auth_timestamp = time
  end

  #
  # return the session id
  #
  def get_id
    @id
  end
  
  #
  # return the nonce
  #
  def get_nonce
    @nonce
  end

  #
  # return the auth_timestamp
  #
  def get_auth_timestamp
    @auth_timestamp
  end

  #
  # Check if nonce valid
  #
  def valid_nonce?(request)

    # check if a valid session
    return false if not valid_session?(request)
    return false if @nonce.nil?
    return false if not request.request_method.eql? "POST"

    # get nonce from request
    request_nonce = request.query['nonce']
    return false if request_nonce.nil?
    
    # verify nonce
    request_nonce.eql? @nonce
    
  end

  #
  # Check if a session valid
  #
  def valid_session?(request)

    # check if a valid session exists
    return false if @id.nil?
    return false if @ip.nil?

    # check ip address matches
    return false if not @ip.to_s.eql? request.peeraddr[3]

    # get session cookie name from config
    config = BeEF::Configuration.instance
    session_cookie_name = config.get('session_cookie_name')
    
    # check session id matches
    request.cookies.each{|cookie|
      c = WEBrick::Cookie.parse_set_cookie(cookie.to_s)
      return true if (c.name.to_s.eql? session_cookie_name) and (c.value.eql? @id) 
    }
    
    # not a valid session 
    false 
  end

end

end
end