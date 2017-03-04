#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
#
# Generic Http Handler that extensions can use to register http
# controllers into the framework.
#
module BeEF
  module Extension
    module AdminUI
      module Handlers
        class Ngui < BeEF::Core::Router::Router

         #  # aui = BeEF::Extension::AdminUI::API::Handler.mount
         #
         # get '/ui/media' do
         #   print_info  "PATH ---> " + aui[1]
         #   Rack::File.new(aui[1])
         # end

          get '/dio' do
            'DIO'
          end

         get '/ui/web_ui_all.js' do
               'LOOL'
         end

         get '/ui/web_ui_auth.js' do
                'LOOOL2'
         end

        end
      end
    end
  end
end
