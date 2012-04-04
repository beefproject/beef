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

        # @note Override default 404 HTTP response
        not_found do
          if config.get("beef.http.web_server_imitation.enable")
            type = config.get("beef.http.web_server_imitation.type")
            case type
              when "apache"
                #response body
                "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">" +
                    "<html><head>" +
                    "<title>404 Not Found</title>" +
                    "</head><body>" +
                    "<h1>Not Found</h1>" +
                    "<p>The requested URL was not found on this server.</p>" +
                    "<hr>" +
                    "<address>Apache/2.2.3 (CentOS)</address>" +
                    "</body></html>"
              when "iis"
                #response body
                "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">" +
                    "<HTML><HEAD><TITLE>The page cannot be found</TITLE>" +
                    "<META HTTP-EQUIV=\"Content-Type\" Content=\"text/html; charset=Windows-1252\">" +
                    "<STYLE type=\"text/css\">" +
                    "  BODY { font: 8pt/12pt verdana } " +
                    "  H1 { font: 13pt/15pt verdana }" +
                    "  H2 { font: 8pt/12pt verdana }" +
                    "  A:link { color: red }" +
                    "  A:visited { color: maroon }" +
                    "</STYLE>" +
                    "</HEAD><BODY><TABLE width=500 border=0 cellspacing=10><TR><TD>" +
                    "<h1>The page cannot be found</h1>" +
                    "The page you are looking for might have been removed, had its name changed, or is temporarily unavailable." +
                    "<hr>" +
                    "<p>Please try the following:</p>" +
                    "<ul>" +
                    "<li>Make sure that the Web site address displayed in the address bar of your browser is spelled and formatted correctly.</li>" +
                    "<li>If you reached this page by clicking a link, contact" +
                    " the Web site administrator to alert them that the link is incorrectly formatted." +
                    "</li>" +
                    "<li>Click the <a href=\"javascript:history.back(1)\">Back</a> button to try another link.</li>" +
                    "</ul>" +
                    "<h2>HTTP Error 404 - File or directory not found.<br>Internet Information Services (IIS)</h2>" +
                    "<hr>" +
                    "<p>Technical Information (for support personnel)</p>" +
                    "<ul>" +
                    "<li>Go to <a href=\"http://go.microsoft.com/fwlink/?linkid=8180\">Microsoft Product Support Services</a> and perform a title search for the words <b>HTTP</b> and <b>404</b>.</li>" +
                    "<li>Open <b>IIS Help</b>, which is accessible in IIS Manager (inetmgr)," +
                    "and search for topics titled <b>Web Site Setup</b>, <b>Common Administrative Tasks</b>, and <b>About Custom Error Messages</b>.</li>" +
                    "</ul>" +
                    "</TD></TR></TABLE></BODY></HTML>"
              else
                "Not Found."
            end
          else
            "Not Found."
          end
        end

        before do
          # @note Override Server HTTP response header
          if config.get("beef.http.web_server_imitation.enable")
             type = config.get("beef.http.web_server_imitation.type")
             case type
               when "apache"
                headers "Server" => "Apache/2.2.3 (CentOS)",
                        "Content-Type" => "text/html"

               when "iis"
                headers "Server" => "Microsoft-IIS/7.0",
                        "X-Powered-By" => "ASP.NET",
                        "Content-Type" => "text/html"
               else
                 print_error "You have and error in beef.http.web_server_imitation.type! Supported values are: apache, iis."
             end
          end
        end
      end
    end
  end
end