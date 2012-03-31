#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
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
  module Core
    module Router

      #@note This is the main Router parent class.
      #@note All the HTTP handlers registered on BeEF will extend this class.
      class Router < Sinatra::Base

        config = BeEF::Core::Configuration.instance
        configure do set :show_exceptions, false end
        not_found do 'Not Found' end

        before do
          # @note Override Server HTTP response header
          if config.get("beef.http.web_server_imitation.enable")
             type = config.get("beef.http.web_server_imitation.type")
             case type
               when "apache"
                headers "Server" => "Apache/2.2.3 (CentOS)"

                #todo https://github.com/beefproject/beef/issues/98 if web_server imitation is enabled
                #todo the 404 response will be something like the following:
                #<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
                #<html><head>
                #<title>404 Not Found</title>
                #</head><body>
                #<h1>Not Found</h1>
                #<p>The requested URL /aaaa was not found on this server.</p>
                # <hr>
                # <address>Apache/2.2.3 (CentOS)</address>
                # </body></html>

               when "iis"
                headers "Server" => "Microsoft-IIS/7.0"
             end
          end
        end
      end
    end
  end
end