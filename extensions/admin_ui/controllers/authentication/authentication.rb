#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module AdminUI
      module Controllers
        #
        # The authentication web page for BeEF.
        #
        class Authentication < BeEF::Extension::AdminUI::HttpController
          #
          # Constructor
          #
          def initialize
            super({
              'paths' => {
                '/' => method(:index),
                '/login' => method(:login),
                '/logout' => method(:logout)
              }
            })

            @session = BeEF::Extension::AdminUI::Session.instance
          end

          # Function managing the index web page
          def index
            @headers['Content-Type'] = 'text/html; charset=UTF-8'
            @headers['X-Frame-Options'] = 'sameorigin'
          end

          #
          # Function managing the login
          #
          def login
            username = @params['username-cfrm'] || ''
            password = @params['password-cfrm'] || ''
            @headers['Content-Type'] = 'application/json; charset=UTF-8'
            @headers['X-Frame-Options'] = 'sameorigin'
            @body = { success: false }.to_json

            config = BeEF::Core::Configuration.instance
            ua_ip = config.get('beef.http.allow_reverse_proxy') ? @request.ip : @request.get_header('REMOTE_ADDR')

            # check if source IP address is permitted to authenticate
            unless permitted_source?(ua_ip)
              BeEF::Core::Logger.instance.register('Authentication', "IP source address (#{ua_ip}) attempted to authenticate but is not within permitted subnet.")
              return
            end

            # check if under brute force attack
            return unless BeEF::Core::Rest.timeout?('beef.extension.admin_ui.login_fail_delay',
                                                    @session.get_auth_timestamp,
                                                    ->(time) { @session.set_auth_timestamp(time) })

            # check username and password
            unless username.eql?(config.get('beef.credentials.user')) && password.eql?(config.get('beef.credentials.passwd'))
              BeEF::Core::Logger.instance.register('Authentication', "User with ip #{ua_ip} has failed to authenticate in the application.")
              return
            end

            # establish an authenticated session
            @session.set_logged_in(ua_ip)
            session_cookie_name = config.get('beef.extension.admin_ui.session_cookie_name') # get session cookie name
            Rack::Utils.set_cookie_header!(@headers, session_cookie_name, { value: @session.get_id, path: '/', httponly: true })

            BeEF::Core::Logger.instance.register('Authentication', "User with ip #{ua_ip} has successfully authenticated in the application.")
            @body = { success: true }.to_json
          end

          #
          # Function managing the logout
          #
          def logout
            @body = { success: true }.to_json

            unless @session.valid_nonce?(@request)
              print_error 'invalid nonce'
              return
            end

            unless @session.valid_session?(@request)
              print_error 'invalid session'
              return
            end

            @headers['Content-Type'] = 'application/json; charset=UTF-8'
            @headers['X-Frame-Options'] = 'sameorigin'

            # set the session to be log out
            @session.set_logged_out

            # clean up UA and expire the session cookie
            config = BeEF::Core::Configuration.instance
            session_cookie_name = config.get('beef.extension.admin_ui.session_cookie_name') # get session cookie name
            Rack::Utils.set_cookie_header!(@headers, session_cookie_name, { value: '', path: '/', httponly: true, expires: Time.now })

            ua_ip = config.get('beef.http.allow_reverse_proxy') ? @request.ip : @request.get_header('REMOTE_ADDR')
            BeEF::Core::Logger.instance.register('Authentication', "User with ip #{ua_ip} has successfully logged out.")
          end

          #
          # Check the UI browser source IP is within the permitted subnet
          #
          def permitted_source?(ip)
            return false unless BeEF::Filters.is_valid_ip?(ip)

            permitted_ui_subnet = BeEF::Core::Configuration.instance.get('beef.restrictions.permitted_ui_subnet')
            return false if permitted_ui_subnet.nil?
            return false if permitted_ui_subnet.empty?

            permitted_ui_subnet.each do |subnet|
              return true if IPAddr.new(subnet).include?(ip)
            end

            false
          end
        end
      end
    end
  end
end
