#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module AdminUI
module Controllers

#
# The authentication web page for BeEF.
#
class Authentication < BeEF::Extension::AdminUI::HttpController
  
  #
  # Constructor
  #
  def initialize
    super({
      'paths' =>  {
        '/'        => method(:index), 
        '/login'   => method(:login),
        '/logout'  => method(:logout)
      }
    })
    
    @session = BeEF::Extension::AdminUI::Session.instance
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
    config = BeEF::Core::Configuration.instance
    @headers['Content-Type']='application/json; charset=UTF-8'
    ua_ip = @request.ip # get client ip address
    @body = '{ success : false }' # attempt to fail closed
          
    # check if source IP address is permited to authenticate
    if not permited_source?(ua_ip)
      BeEF::Core::Logger.instance.register('Authentication', "IP source address (#{@request.ip}) attempted to authenticate but is not within permitted subnet.")
      return
    end

    # check if under brute force attack  
    time = Time.new
    if not timeout?(time)
      @session.set_auth_timestamp(time)
      return
    end
    
    # check username and password
    if not (username.eql? config.get('beef.credentials.user') and password.eql? config.get('beef.credentials.passwd') )
      BeEF::Core::Logger.instance.register('Authentication', "User with ip #{@request.ip} has failed to authenticate in the application.")
      return
    end
    
    # establish an authenticated session

    # set up session and set it logged in
    @session.set_logged_in(ua_ip) 
      
    # create session cookie 
    session_cookie_name = config.get('beef.http.session_cookie_name') # get session cookie name
    Rack::Utils.set_cookie_header!(@headers, session_cookie_name, {:value => @session.get_id, :path => "/", :httponly => true})
      
    BeEF::Core::Logger.instance.register('Authentication', "User with ip #{@request.ip} has successfuly authenticated in the application.")
    @body = "{ success : true }"
  end
  
  #
  # Function managing the logout
  #
  def logout
    
    # test if session is unauth'd
    (print_error "invalid nonce";return @body = "{ success : true }") if not @session.valid_nonce?(@request)
    (print_error "invalid session";return @body = "{ success : true }") if not @session.valid_session?(@request)
    
    @headers['Content-Type']='application/json; charset=UTF-8'
    
    # set the session to be log out
    @session.set_logged_out
      
    # clean up UA and expire the session cookie
    config = BeEF::Core::Configuration.instance
    session_cookie_name = config.get('beef.http.session_cookie_name') # get session cookie name
    Rack::Utils.set_cookie_header!(@headers, session_cookie_name, {:value => "", :path => "/", :httponly => true, expires: Time.now})

    BeEF::Core::Logger.instance.register('Authentication', "User with ip #{@request.ip} has successfuly logged out.")
    @body = "{ success : true }"
    
  end
  
  #
  # Check the UI browser source IP is within the permitted subnet
  #
  def permited_source?(ip)
    # get permitted subnet 
    config = BeEF::Core::Configuration.instance
    permitted_ui_subnet = config.get('beef.restrictions.permitted_ui_subnet')
    target_network = IPAddr.new(permitted_ui_subnet)
    
    # test if ip within subnet
    return target_network.include?(ip)
  end
  
  #
  # Brute Force Mitigation
  # Only one login request per login_fail_delay seconds 
  #
  def timeout?(time)
    config = BeEF::Core::Configuration.instance
    login_fail_delay = config.get('beef.extension.admin_ui.login_fail_delay') # get fail delay
    
    # test if the last login attempt was less then login_fail_delay seconds
    time - @session.get_auth_timestamp > login_fail_delay.to_i
  end


end

end
end
end
end
