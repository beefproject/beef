#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Rest
      class AdminUi < BeEF::Core::Router::Router

        before do
          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end



        get '/ui/media' do

          # FIX THIS
          Rack::Directory.new("#{File.expand_path('../../../../', __FILE__)}/extensions/admin_ui/media/")
          # TODO fix this to server media dir
        end

        get '/ui/web_ui_all.js' do
          @aui = BeEF::Extension::AdminUI::API::Handler.mount
          File.read(@aui[2])
        end

        get '/ui/web_ui_auth.js' do
          @aui = BeEF::Extension::AdminUI::API::Handler.mount
          File.read(@aui[3])
        end

        # post '/ui/authentication/login' do
        #   request.body.rewind
        #
        #   @session = BeEF::Extension::AdminUI::Session.instance
        #
        # end
      end
    end
  end
end
