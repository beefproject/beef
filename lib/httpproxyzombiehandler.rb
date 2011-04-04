require 'webrick/httprequest'
require 'webrick/httpresponse'

module BeEF
 
  module HttpProxyZombieHandler
    
    # Variable representing the Http DB model.
    H = BeEF::Models::Http
    
    # This function will forward requests to the zombie and 
    # the browser will perform the request. Then the results
    # will be sent back to use
    def forward_request(zombie_id, req, res)

      # Generate a id for the req in the http table and check it doesnt already exist
      http_id = rand(10000)
      http_db = H.first(:id => http_id) || nil
      
      while !http_db.nil?
        http_id = rand(10000)
        http_db = H.first(:id => http_id) || nil
      end

      # some debug info
      puts "[PROXY] Forwarding request #" + http_id.to_s + " from zombie [" + zombie_id.to_s + "]" + " to host [" + req.host.to_s + "]"

      # Saves the new HTTP request to the db for processing by HB
      http = H.new(
        :id => http_id,
        :request => req,
        :method => req.request_method.to_s,
        :domain => req.host.to_s,
        :path => req.path.to_s,
        :date => Time.now,
        :zombie_id => zombie_id
      )
      http.save
      
      # Polls the DB for the response and then sets it when present
      
      http_db = H.first(:id => http_id)
      
      while !http_db.has_ran
        sleep 1
        http_db = H.first(:id => http_id)
      end
      
      res.body = http_db.response
        
      res
    end
    
    module_function :forward_request

  end

end