#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  #
  # Table stores the http requests and responses from the requester.
  #
  class Http < ActiveRecord::Base
    attribute :id, :Serial

    # The hooked browser id
    attribute :hooked_browser_id, :Text, :lazy => false

    # The http request to perform. In clear text.
    attribute :request, :Text, :lazy => true

    # Boolean value as string to say whether cross-domain requests are allowed
    attribute :allow_cross_domain, :Text, :lazy => false, :default => "true"

    # The http response body received. In clear text.
    attribute :response_data, :Binary, :lazy => true, :length => 2097152

    # The http response code. Useful to handle cases like 404, 500, 302, ...
    attribute :response_status_code, :Integer, :lazy => true

    # The http response code. Human-readable code: success, error, ecc..
    attribute :response_status_text, :Text, :lazy => true

   # The port status. closed, open or not http
    attribute :response_port_status, :Text, :lazy => true

    # The XHR Http response raw headers
    attribute :response_headers, :Text, :lazy => true

    # The http response method. GET or POST.
    attribute :method, :Text, :lazy => false

    # The content length for the request.
    attribute :content_length, :Text, :lazy => false, :default => 0

    # The request protocol/scheme (http/https)
    attribute :proto, :Text, :lazy => false

    # The domain on which perform the request.
    attribute :domain, :Text, :lazy => false

    # The port on which perform the request.
    attribute :port, :Text, :lazy => false

    # Boolean value to say if the request was cross-domain
    attribute :has_ran, :Text, :lazy => false, :default => "waiting"

    # The path of the request.
    # Example: /secret.html
    attribute :path, :Text, :lazy => false

    # The date at which the http response has been saved.
    attribute :response_date, :DateTime, :lazy => false

    # The date at which the http request has been saved.
    attribute :request_date, :DateTime, :lazy => false

    # Removes a request/response from the data store
    #
    def self.delete(id)
      (print_error "Failed to remove response. Invalid response ID."; return) if id.to_s !~ /\A\d+\z/
      r = BeEF::Core::Models::Http.get(id.to_i)
      (print_error "Failed to remove response [id: #{id}]. Response does not exist."; return) if r.nil?
      r.destroy
    end
  end
end
end
end
