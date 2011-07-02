#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
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
  
  # Send a new http request to the hooked browser.
  def send_request
    # validate that the hooked browser's session has been sent
    zombie_session = @params['zombie_session'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "Invalid session id" if not BeEF::Filters.is_valid_hook_session_id?(zombie_session)
    
    # validate that the hooked browser exists in the db
    zombie = Z.first(:session => zombie_session) || nil
    raise WEBrick::HTTPStatus::BadRequest, "Invalid hooked browser session" if zombie.nil?
    
    # validate that the raw request has been sent
    raw_request = @params['raw_request'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "raw_request is nil" if raw_request.nil?
    raise WEBrick::HTTPStatus::BadRequest, "raw_request contains non-printable chars" if not BeEF::Filters.has_non_printable_char?(raw_request)
    
    # validate nonce
    nonce = @params['nonce'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "nonce is nil" if nonce.nil?
    raise WEBrick::HTTPStatus::BadRequest, "nonce incorrect" if @session.get_nonce != nonce
    
    # validate that the raw request is correct and can be used
    req_parts = raw_request.split(/ |\n/) # break up the request
    verb = req_parts[0]
    raise 'Only GET or POST requests are supported' if not BeEF::Filters.is_valid_verb?(verb) #check verb
    uri = req_parts[1]
    raise 'Invalid URI' if not BeEF::Filters.is_valid_url?(uri) #check uri
    version = req_parts[2]
    raise 'Invalid HTTP version' if not BeEF::Filters.is_valid_http_version?(version) # check http version - HTTP/1.0
    host_str = req_parts[3]
    raise 'Invalid HTTP version' if not BeEF::Filters.is_valid_host_str?(host_str) # check host string - Host:
    host = req_parts[4]
    host_parts = host.split(/:/)
    hostname = host_parts[0]
    raise 'Invalid hostname' if not BeEF::Filters.is_valid_hostname?(hostname) #check the target hostname
    hostport = host_parts[1] || nil
    if !hostport.nil?
        raise 'Invalid hostport' if not BeEF::Filters.nums_only?(hostport) #check the target hostport
    end

    # (re)build the request
    green_request = StringIO.new(verb + " " + uri + " " +  version + "\n" + host_str + " " + host)
    request = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
    request.parse(green_request)
        
    # Saves the new HTTP request.
    http = H.new(
      :request => raw_request,
      :method => request.request_method,
      :domain => request.host,
      :path => request.unparsed_uri,
      :request_date => Time.now,
      :hooked_browser_id => zombie.id
    )
    
    if request.request_method.eql? 'POST'
      http.content_length = request.content_length
    end
    
    http.save
    
    @body = '{success : true}'
  end
  
  # Returns a JSON object containing the history of requests sent to the zombie.
  def get_zombie_history
    # validate nonce
    nonce = @params['nonce'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "nonce is nil" if nonce.nil?
    raise WEBrick::HTTPStatus::BadRequest, "nonce incorrect" if @session.get_nonce != nonce
    
    # validate that the hooked browser's session has been sent
    zombie_session = @params['zombie_session'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "Zombie session is nil" if zombie_session.nil?
    
    # validate that the hooked browser exists in the db
    zombie = Z.first(:session => zombie_session) || nil
    raise WEBrick::HTTPStatus::BadRequest, "Invalid hooked browser session" if zombie.nil?
    
    history = []
    H.all(:hooked_browser_id => zombie.id).each{|http|
      history << {
        'id'      => http.id,
        'domain'  => http.domain,
        'path'    => http.path,
        'has_ran' => http.has_ran,
        'request_date'    => http.request_date,
        'response_date'    => http.response_date,
        'response_status_code'    => http.response_status_code,
        'response_status_text'    => http.response_status_text
      }
    }
    
    @body = {'success' => 'true', 'history' => history}.to_json
  end
  
  # Returns a JSON objecting containing the response of a request.
  def get_zombie_response
    # validate nonce
    nonce = @params['nonce'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "nonce is nil" if nonce.nil?
    raise WEBrick::HTTPStatus::BadRequest, "nonce incorrect" if @session.get_nonce != nonce
    
    # validate the http id
    http_id = @params['http_id'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "http_id is nil" if http_id.nil?
    
    # validate that the http object exist in the dabatase
    http_db = H.first(:id => http_id) || nil
    raise WEBrick::HTTPStatus::BadRequest, "http object could not be found in the database" if http_db.nil?
    
    res = {
      'id'        => http_db.id,
      'request'   => http_db.request,
      'response'  => http_db.response_data,
      'domain'    => http_db.domain,
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
