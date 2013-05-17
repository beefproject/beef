#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# GET:
#   * Rule count
#   * List of rules

# POST:
#   * Add rule
#   * Remove rule


# /api/dns/rules
# {
#   "rules": [
#       {
#           "id": 1,
#           "pattern": "foobar.com",
#           "type": "Resolv::DNS::Resource::IN::A"
#           "block": "proc {|t| ...do shit... }"
#       },
#
#       {
#       },
#
#       {
#       },
#   ]
# }



module BeEF
module Extension
module DNS

  class DNSRest < BeEF::Core::Router::Router

    before do
      config = BeEF::Core::Configuration.instance

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
      result[:rules] = BeEF::Extension::DNS::DNS.instance.get_rules
      result.to_json
    end

  end

end
end
end
