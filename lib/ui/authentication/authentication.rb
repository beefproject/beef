module BeEF
module UI

#
# The authentication web page for BeEF.
#
class Authentication < BeEF::HttpController
  
  #
  # Constructor
  #
  def initialize
    super({
      'paths' =>  {
        'index' => '/',
        'login' => '/login',
        'logout' => '/logout'
      }
    })
    
    @session = BeEF::UI::Session.instance
  end
  
  # Function managing the index web page
  def index 
    @headers['Content-Type']='text/html; charset=UTF-8'
  end
  
  #
  # Function managing the login
  #
  def login
    username = @params['username-cfrm'] || ''
    password = @params['password-cfrm'] || ''
    config = BeEF::Configuration.instance
    @headers['Content-Type']='application/json; charset=UTF-8'
    ua_ip = @request.peeraddr[3] # get client ip address
    @body = '{ success : false }' # attempt to fail closed
          
    # check if source IP address is permited to authenticate
    if not permited_source?(ua_ip)
      BeEF::Logger.instance.register('Authentication', "IP source address (#{@request.peeraddr[3]}) attempted to authenticate but is not within permitted subnet.")
      return
    end

    # check if under brute force attack  
    time = Time.new
    if not timeout?(time)
      @session.set_auth_timestamp(time)
      return
    end
    
    # check username and password
    if not (username.eql? config.get('ui_username') and password.eql? config.get('ui_password') )
      BeEF::Logger.instance.register('Authentication', "User with ip #{@request.peeraddr[3]} has failed to authenticate in the application.")
      return
    end
    
    # establish an authenticated session

    # set up session and set it logged in
    @session.set_logged_in(ua_ip) 
      
    # create session cookie 
    session_cookie_name = config.get('session_cookie_name') # get session cookie name
    session_cookie = WEBrick::Cookie.new(session_cookie_name, @session.get_id)
    session_cookie.path = '/'
    session_cookie.httponly = true
      
    # add session cookie to response header
    @headers['Set-Cookie'] = session_cookie.to_s
      
    # TODO add escape username and password submitted
    BeEF::Logger.instance.register('Authentication', "User with ip #{@request.peeraddr[3]} has successfuly authenticated in the application.")
    @body = "{ success : true }"
  end
  
  #
  # Function managing the logout
  #
  def logout
    
    # test if session is unauth'd
    raise WEBrick::HTTPStatus::BadRequest, "invalid nonce" if not @session.valid_nonce?(@request)
    raise WEBrick::HTTPStatus::BadRequest, "invalid session" if not @session.valid_session?(@request)    
    
    @headers['Content-Type']='application/json; charset=UTF-8'
    
    # set the session to be log out
    @session.set_logged_out
      
    # clean up UA and expire the session cookie
    config = BeEF::Configuration.instance
    session_cookie_name = config.get('session_cookie_name') # get session cookie name
    session_cookie = WEBrick::Cookie.new(session_cookie_name, "")
    session_cookie.path = '/'
    session_cookie.expires = Time.now
    session_cookie.httponly = true
      
    # add (expired) session cookie to response header
    @headers['Set-Cookie'] = session_cookie.to_s
      
    BeEF::Logger.instance.register('Authentication', "User with ip #{@request.addr} has successfuly logged out.")
    @body = "{ success : true }"
    
  end
  
  #
  # Check the UI browser source IP is within the permitted subnet
  #
  def permited_source?(ip)
    # get permitted subnet 
    config = BeEF::Configuration.instance
    permitted_ui_subnet = config.get('permitted_ui_subnet')
    target_network = IPAddr.new(permitted_ui_subnet)
    
    # test if ip within subnet
    return target_network.include?(ip)
  end
  
  #
  # Brute Force Mitigation
  # Only one login request per login_fail_delay seconds 
  #
  def timeout?(time)
    config = BeEF::Configuration.instance
    login_fail_delay = config.get('login_fail_delay') # get fail delay
    
    # test if the last login attempt was less then login_fail_delay seconds
    time - @session.get_auth_timestamp > login_fail_delay.to_i
  end


end

end
end