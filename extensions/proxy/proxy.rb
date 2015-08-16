#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'openssl';

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

          ssl_context = OpenSSL::SSL::SSLContext.new
          ssl_context.cert = OpenSSL::X509::Certificate.new(File.open(@conf.get('beef.extension.proxy.cert')));
          ssl_context.key = OpenSSL::PKey::RSA.new(File.open(@conf.get('beef.extension.proxy.key')));

          ssl_server = OpenSSL::SSL::SSLServer.new(@proxy_server, ssl_context);
          ssl_server.start_immediately = false;

          loop do
            ssl_socket = ssl_server.accept
            Thread.new ssl_socket, &method(:handle_request)
          end
        end

        def handle_request socket
          request_line = socket.readline

          # HTTP method # defaults to GET
          method = request_line[/^\w+/]

          if method == "CONNECT" then
            # request_line is something like:
            # CONNECT example.com:443 HTTP/1.1
            host_port = request_line.split(" ")[1]
            url_prefix = "https://" + host_port
            loop do
              line = socket.readline
              if line.strip.empty?
                break
              end
            end
            socket.puts("HTTP/1.0 200 Connection established\r\n\r\n")
            socket.accept
            print_debug("[PROXY] Handled CONNECT to #{host_port}")
            request_line = socket.readline
            method = request_line[/^\w+/]
          else
            url_prefix = ""
          end

          # HTTP version # defaults to 1.0
          version = request_line[/HTTP\/(1\.\d)\s*$/, 1]
          version = "HTTP/1.0" if version.nil?

          # url # host:port/path
          url = url_prefix + request_line[/^\w+\s+(\S+)/, 1]

          # We're overwriting the URI::Parser UNRESERVED regex to prevent BAD URI errors when sending attack vectors (see tolerant_parser)
          # anti: somehow the config below was removed, have a look into this
          tolerant_parser = URI::Parser.new(:UNRESERVED => BeEF::Core::Configuration.instance.get("beef.extension.requester.uri_unreserved_chars"))
          uri = tolerant_parser.parse(url.to_s)

          method, path, version = request_line.split(" ")
          path = url_prefix + path
          # extensions/requester/api/hook.rb parses raw_request to find port and path
          raw_request = [method, path, version].join(" ") + "\r\n"
          content_length = 0

          loop do
            line = socket.readline

            if line =~ /^Content-Length:\s+(\d+)\s*$/
              content_length = $1.to_i
            end

            if line.strip.empty?
              # read data still in the socket, exactly <content_length> bytes
              if content_length >= 0
                raw_request += "\r\n" + socket.read(content_length)
              end
              break
            else
              raw_request += line
            end
          end

          # Saves the new HTTP request to the db. It will be processed by the PreHookCallback of the requester component.
          # IDs are created and incremented automatically by DataMapper.
          http = H.new(
              :request => raw_request,
              :method => method,
              :domain => uri.host,
              :port => uri.port,
              :path => uri.path,
              :request_date => Time.now,
              :hooked_browser_id => self.get_tunneling_proxy,
              :allow_cross_domain => "true"
          )
          http.save
          print_debug("[PROXY] --> Forwarding request ##{http.id}: domain[#{http.domain}:#{http.port}], method[#{http.method}], path[#{http.path}], cross domain[#{http.allow_cross_domain}]")

          # Wait for the HTTP response to be stored in the db.
          # TODO: re-implement this with EventMachine or with the Observer pattern.
          while H.first(:id => http.id).has_ran != "complete"
            sleep 0.5
          end
          @response = H.first(:id => http.id)
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
          response_headers = ""
          if (response_status != -1 && response_status != 0)
            ignore_headers = [
              "Content-Encoding",
              "Keep-Alive",
              "Cache-Control", 
              "Vary",
              "Pragma",
              "Connection",
              "Expires",
              "Accept-Ranges",
              "Date"]
            headers.each_line do |line|
              # stripping the Encoding, Cache and other headers
              header_key = line.split(': ')[0]
              header_value = line.split(': ')[1]
              next if header_key.nil?
              next if ignore_headers.include?(header_key)
              if header_value.nil?
                #headers_hash[header_key] = ""
              else
                # update Content-Length with the valid one
                if header_key == "Content-Length"
                  response_headers += "Content-Length: #{response_body.size}\r\n"
                else
                  response_headers += line
                end
              end
            end
          end

          res = "#{version} #{response_status}\r\n#{response_headers}\r\n\r\n#{response_body}"
          socket.write(res)
          socket.close
        end

        def get_tunneling_proxy
          proxy_browser = HB.first(:is_proxy => true)
          if (proxy_browser != nil)
            proxy_browser_id = proxy_browser.id.to_s
          else
            proxy_browser_id = 1
            print_debug "[PROXY] Proxy browser not set. Defaulting to browser id #1"
          end
          proxy_browser_id
        end
      end
    end
  end
end

