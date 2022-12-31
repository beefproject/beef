#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module AdminUI
      #
      # Handle HTTP requests and call the relevant functions in the derived classes
      #
      class HttpController
        attr_accessor :headers, :status, :body, :paths, :currentuser, :params

        C = BeEF::Core::Models::Command
        CM = BeEF::Core::Models::CommandModule
        Z = BeEF::Core::Models::HookedBrowser

        #
        # Class constructor. Takes data from the child class and populates itself with it.
        #
        def initialize(data = {})
          @erubis = nil
          @status = 200 if data['status'].nil?
          @session = BeEF::Extension::AdminUI::Session.instance

          @config = BeEF::Core::Configuration.instance
          @bp = @config.get 'beef.extension.admin_ui.base_path'

          @headers = { 'Content-Type' => 'text/html; charset=UTF-8' } if data['headers'].nil?

          @paths = if data['paths'].nil? && methods.include?('index')
                     { 'index' => '/' }
                   else
                     data['paths']
                   end
        end

        #
        # Authentication check. Confirm the request to access the UI comes from a permitted IP address
        #
        def authenticate_request(ip)
          auth = BeEF::Extension::AdminUI::Controllers::Authentication.new
          auth.permitted_source?(ip)
        rescue StandardError => e
          print_error "authenticate_request failed: #{e.message}"
          false
        end

        #
        # Check if reverse proxy has been enabled and return the correct client IP address
        #
        def get_ip(request)
          if @config.get('beef.http.allow_reverse_proxy')
            request.ip # Get client x-forwarded-for ip address
          else
            request.get_header('REMOTE_ADDR') # Get client remote ip address
          end
        end

        #
        # Handle HTTP requests and call the relevant functions in the derived classes
        #
        def run(request, response)
          @request = request
          @params = request.params

          @body = ''

          # If access to the UI is not permitted for the request IP address return a 404
          unless authenticate_request(get_ip(@request))
            @status = 404
            return
          end

          # test if session is unauth'd and whether the auth functionality is requested
          if !@session.valid_session?(@request) && !instance_of?(BeEF::Extension::AdminUI::Controllers::Authentication)
            @status = 302
            @headers = { 'Location' => "#{@bp}/authentication" }
            return
          end

          # get the mapped function (if it exists) from the derived class
          path = request.path_info
          unless BeEF::Filters.is_valid_path_info?(path)
            print_error "[Admin UI] Path is not valid: #{path}"
            return
          end

          function = @paths[path] || @paths[path + '/'] # check hash for '<path>' and '<path>/'
          if function.nil?
            print_error "[Admin UI] Path does not exist: #{path}"
            return
          end

          # call the relevant mapped function
          function.call

          # build the template filename and apply it - if the file exists
          function_name = function.name # used for filename
          class_s = self.class.to_s.sub('BeEF::Extension::AdminUI::Controllers::', '').downcase # used for directory name
          template_ui = "#{$root_dir}/extensions/admin_ui/controllers/#{class_s}/#{function_name}.html"
          if File.exist?(template_ui)
            @eruby = Erubis::FastEruby.new(File.read(template_ui))
            @body = @eruby.result(binding) unless @eruby.nil? # apply template and set the response
          end

          # set appropriate content-type 'application/json' for .json files
          @headers['Content-Type'] = 'application/json; charset=UTF-8' if request.path.to_s.end_with?('.json')

          # set content type
          if @headers['Content-Type'].nil?
            @headers['Content-Type'] = 'text/html; charset=UTF-8' # default content and charset type for all pages
          end
        rescue StandardError => e
          print_error "Error handling HTTP request: #{e.message}"
          print_error e.backtrace
        end

        # Constructs a html script tag (from media/javascript directory)
        def script_tag(filename)
          "<script src=\"#{@bp}/media/javascript/#{filename}\" type=\"text/javascript\"></script>"
        end

        # Constructs a html script tag (from media/javascript-min directory)
        def script_tag_min(filename)
          "<script src=\"#{@bp}/media/javascript-min/#{filename}\" type=\"text/javascript\"></script>"
        end

        # Constructs a html stylesheet tag
        def stylesheet_tag(filename)
          "<link rel=\"stylesheet\" href=\"#{@bp}/media/css/#{filename}\" type=\"text/css\" />"
        end

        # Constructs a hidden html nonce tag
        def nonce_tag
          "<input type=\"hidden\" name=\"nonce\" id=\"nonce\" value=\"#{@session.get_nonce}\"/>"
        end

        def base_path
          @bp.to_s
        end

        private

        @eruby

        # Unescapes a URL-encoded string.
        def unescape(s)
          s.tr('+', ' ').gsub(/%([\da-f]{2})/in) { [Regexp.last_match(1)].pack('H*') }
        end
      end
    end
  end
end
