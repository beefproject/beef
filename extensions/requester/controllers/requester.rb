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
# HTTP Controller for the Requester component of BeEF.
#
class Requester < BeEF::Extension::AdminUI::HttpController
  
  # Variable representing the Http DB model.
  H = BeEF::Core::Models::Http
  
  def initialize
    super({
      'paths' => {
        '/send'           => method(:send_request),
        '/history.json'   => method(:get_zombie_history),
        '/response.json'  => method(:get_zombie_response)
      }
    })
  end

  def err_msg(error)
     print_error "[REQUESTER] #{error}"
  end
  
  # Send a new http request to the hooked browser.
  def send_request
    # validate that the hooked browser's session has been sent
    zombie_session = @params['zombie_session'] || nil
    (self.err_msg "Invalid session id";return @body = '{success : false}') if not BeEF::Filters.is_valid_hook_session_id?(zombie_session)
    
    # validate that the hooked browser exists in the db
    zombie = Z.first(:session => zombie_session) || nil
    (self.err_msg "Invalid hooked browser session";return @body = '{success : false}') if zombie.nil?
    
    # validate that the raw request has been sent
    raw_request = @params['raw_request'] || nil
    (self.err_msg "raw_request is nil";return @body = '{success : false}') if raw_request.nil?
    (self.err_msg "raw_request contains non-printable chars";return @body = '{success : false}') if not BeEF::Filters.has_non_printable_char?(raw_request)
    
    # validate nonce
    nonce = @params['nonce'] || nil
    (self.err_msg "nonce is nil";return @body = '{success : false}') if nonce.nil?
    (self.err_msg "nonce incorrect";return @body = '{success : false}') if @session.get_nonce != nonce
    
    # validate that the raw request is correct and can be used
    req_parts = raw_request.split(/ |\n/) # break up the request

    verb = req_parts[0]
    self.err_msg 'Only HEAD, GET, POST, OPTIONS, PUT or DELETE requests are supported' if not BeEF::Filters.is_valid_verb?(verb) #check verb

    uri = req_parts[1]
    (self.err_msg 'Invalid URI';return @body = '{success : false}') if not BeEF::Filters.is_valid_url?(uri) #check uri

    version = req_parts[2]
    (self.err_msg 'Invalid HTTP version';return @body = '{success : false}') if not BeEF::Filters.is_valid_http_version?(version) # check http version - HTTP/1.0 or HTTP/1.1

    host_str = req_parts[3]
    (self.err_msg 'Invalid HTTP Host Header';return @body = '{success : false}') if not BeEF::Filters.is_valid_host_str?(host_str) # check host string - Host:

    host = req_parts[4]
    host_parts = host.split(/:/)
    hostname = host_parts[0]
    (self.err_msg 'Invalid HTTP HostName';return @body = '{success : false}') if not BeEF::Filters.is_valid_hostname?(hostname) #check the target hostname

    hostport = host_parts[1] || nil
    if !hostport.nil?
        (self.err_msg 'Invalid HTTP HostPort';return @body = '{success : false}') if not BeEF::Filters.nums_only?(hostport) #check the target hostport
    end

    # Saves the new HTTP request.
    http = H.new(
      :request => raw_request,
      :method => verb,
      :domain => hostname,
      :port => hostport,
      :path => uri,
      :request_date => Time.now,
      :hooked_browser_id => zombie.id,
      :allow_cross_domain => "true",
    )
    
    if verb.eql? 'POST'
      req_parts.each_with_index do |value, index|
         if value.match(/^Content-Length/)
           http.content_length = req_parts[index+1]
         end
      end
    end
    
    http.save
    
    @body = '{success : true}'
  end
  
  # Returns a JSON object containing the history of requests sent to the zombie.
  def get_zombie_history
    # validate nonce
    nonce = @params['nonce'] || nil
    (self.err_msg "nonce is nil";return @body = '{success : false}') if nonce.nil?
    (self.err_msg "nonce incorrect";return @body = '{success : false}') if @session.get_nonce != nonce
    
    # validate that the hooked browser's session has been sent
    zombie_session = @params['zombie_session'] || nil
    (self.err_msg "Zombie session is nil";return @body = '{success : false}') if zombie_session.nil?
    
    # validate that the hooked browser exists in the db
    zombie = Z.first(:session => zombie_session) || nil
    (self.err_msg "Invalid hooked browser session";return @body = '{success : false}') if zombie.nil?
    
    history = []
    H.all(:hooked_browser_id => zombie.id).each{|http|
      history << {
        'id'      => http.id,
        'domain'  => http.domain,
	      'port'    => http.port,
        'path'    => http.path,
        'has_ran' => http.has_ran,
        'method'  => http.method,
        'request_date'    => http.request_date,
        'response_date'    => http.response_date,
        'response_status_code'    => http.response_status_code,
        'response_status_text'    => http.response_status_text,
	      'response_port_status'    => http.response_port_status
      }
    }
    
    @body = {'success' => 'true', 'history' => history}.to_json
  end
  
  # Returns a JSON objecting containing the response of a request.
  def get_zombie_response
    # validate nonce
    nonce = @params['nonce'] || nil
    (self.err_msg "nonce is nil";return @body = '{success : false}') if nonce.nil?
    (self.err_msg "nonce incorrect";return @body = '{success : false}') if @session.get_nonce != nonce
    
    # validate the http id
    http_id = @params['http_id'] || nil
    (self.err_msg "http_id is nil";return @body = '{success : false}') if http_id.nil?
    
    # validate that the http object exist in the dabatase
    http_db = H.first(:id => http_id) || nil
    (self.err_msg "http object could not be found in the database";return @body = '{success : false}') if http_db.nil?
    
    if http_db.response_data.length > (1024 * 100) #more thank 100K
      response_data = http_db.response_data[0..(1024*100)]
      response_data += "\n<---------- Response Data Truncated---------->"
    else
      response_data = http_db.response_data
    end
    
    res = {
      'id'        => http_db.id,
      'request'   => http_db.request,
      'response'  => response_data,
      'response_headers' => http_db.response_headers,
      'domain'    => http_db.domain,
      'port'      => http_db.port,
      'path'      => http_db.path,
      'date'      => http_db.request_date,
      'has_ran'   => http_db.has_ran
    }
    
    @body = {'success' => 'true', 'result' => res}.to_json
  end
  
end

end
end
end
end
