#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
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
# The following file contains patches for WEBrick.
module WEBrick
  
  class HTTPRequest
    
    # I'm patching the HTTPRequest class so that it when it receives POST
    # http requests, it parses the query present in the body even if the
    # content type is not set.
    #
    # The reason for this patch is that when a zombie sends back data to
    # BeEF, that data was not parsed because by default the content-type
    # was not set directly. I prefer patching WEBrick rather than editing
    # the BeEFJS library because cross domain http requests would be harder
    # to implement at the server level.
    #
    # Note: this function would need to be modified if we ever needed to
    # use multipart POST requests.
    def parse_query()
      begin
        if @request_method == "GET" || @request_method == "HEAD"
          @query = HTTPUtils::parse_query(@query_string)
        elsif @request_method == 'POST' || self['content-type'] =~ /^application\/x-www-form-urlencoded/
          @query = HTTPUtils::parse_query(body)
        elsif self['content-type'] =~ /^multipart\/form-data; boundary=(.+)/
          boundary = HTTPUtils::dequote($1)
          @query = HTTPUtils::parse_form_data(body, boundary)
        else
          @query = Hash.new
        end
      rescue => ex
        raise HTTPStatus::BadRequest, ex.message
      end
    end
    
    def get_cookie_value(name)
      
      return nil if name.nil?
      
      @cookies.each{|cookie|
        c = WEBrick::Cookie.parse_set_cookie(cookie.to_s)
        return c.value if (c.name.to_s.eql? name)
      }
      
      nil
      
    end
    
    def get_referer_domain
  
      referer = header['referer'][0]
      
      if referer =~ /\:\/\/([0-9a-zA-A\.]*(\:[0-9]+)?)\//   
        return $1
      end
      
      nil

    end

    def get_hook_session_id()
      
      config = BeEF::Core::Configuration.instance
      hook_session_name = config.get('beef.http.hook_session_name')
      
      @query[hook_session_name] || nil
       
    end

    # return the command module command_id value from the request
    def get_command_id()
      @query['command_id'] || nil
    end

    #
    # Attack vectors send through the Requester/Proxy by default  are parsed as Bad URIs, and not sent.
    # For example: request like the following: http://192.168.10.128/dvwa/vulnerabilities/xss_r/?name=ciccioba83e<a>7918817a3ad
    # is blocked  (ERROR bad URI)
    # We're overwriting the URI Parser UNRESERVED regex to prevent such behavior (see tolerant_parser)
    #
    def parse_uri(str, scheme="http")
      if @config[:Escape8bitURI]
        str = HTTPUtils::escape8bit(str)
      end

      tolerant_parser = URI::Parser.new(:UNRESERVED => BeEF::Core::Configuration.instance.get("beef.extension.requester.uri_unreserved_chars"))
      uri = tolerant_parser.parse(str)
      return uri if uri.absolute?
      if @forwarded_host
        host, port = @forwarded_host, @forwarded_port
      elsif self["host"]
        pattern = /\A(#{URI::REGEXP::PATTERN::HOST})(?::(\d+))?\z/n
        host, port = *self['host'].scan(pattern)[0]
      elsif @addr.size > 0
        host, port = @addr[2], @addr[1]
      else
        host, port = @config[:ServerName], @config[:Port]
      end
      uri.scheme = @forwarded_proto || scheme
      uri.host = host
      uri.port = port ? port.to_i : nil

      return tolerant_parser::parse(uri.to_s)
    end

    
  end
  
end
