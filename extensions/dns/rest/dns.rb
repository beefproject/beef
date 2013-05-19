#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module DNS

  # This class handles the routing of RESTful API requests that query BeEF's DNS server
  class DNSRest < BeEF::Core::Router::Router

    # Filters out bad requests before performing any routing
    before do
      config = BeEF::Core::Configuration.instance

      # Require a valid API token from a valid IP address
      error 401 unless params[:token] == config.get('beef.api_token')
      halt  401 unless BeEF::Core::Rest.permitted_source?(request.ip)

      headers 'Content-Type' => 'application/json; charset=UTF-8',
              'Pragma' => 'no-cache',
              'Cache-Control' => 'no-cache',
              'Expires' => '0'
    end

    # Returns the entire current DNS ruleset
    get '/rules' do
      result = {}
      result[:rules] = BeEF::Extension::DNS::DNS.instance.get_ruleset
      result.to_json
    end

    # Returns a specific rule given its id
    get '/rule/:id' do
      id = params[:id]

      halt 401 unless BeEF::Filters.nums_only?(id)

      result = BeEF::Extension::DNS::DNS.instance.get_rule(id)
      result.to_json
    end

  end

end
end
end
