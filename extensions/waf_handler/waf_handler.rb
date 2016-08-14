#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'json'
require 'base64'
require 'sinatra/base'

module BeEF
  module Extension
    module Waf_handler
    
      class ServerHandler < Sinatra::Base
        jsonString = File.read('/home/pavel/beef/extensions/waf_handler/signatures.json')
        @@signatures = JSON.parse(jsonString)
        @@detect = '0'
        @@cookResult = 'IN COOKIES : Nothing was found'
        @@headResult = 'IN HEADERS : Nothing was found'
        
        post '/' do
          request.body.rewind
          payload = JSON.parse(request.body.read, symbolize_names: true)
          cookies = payload[:cookie].split(/[;=]+/)
          headers = payload[:headers].split(';')

          if cookies.empty?
            @@cookResult = 'IN COOKIES : Cookies are empty'
          else
            @@signatures['WAF'].each do |waf|
              waf['cookie'].each do |patternCookie|
                cookies.each do |cookie|
                  if cookie.scan(patternCookie).any?
                    @@cookResult = 'IN COOKIES : ' + waf['name'] + ' was found'
                    return @@detect = '1'
                  end
								end
              end
						end
          end

          if headers.empty?
            @@headResult = 'IN HEADERS : Headers are empty'
          else
            @@signatures['WAF'].each do |waf|
              waf['headers'].each do |patternHeader|
                headers.each do |header|
                  if header.scan(patternHeader).any?
                    @@headResult = 'IN HEADERS : ' + waf['name'] + ' was found'
		                return @@detect = '1'
	                end
	              end
	            end
            end
          end	
        end

        get '/' do
          headers 'Detect' => @@detect
          headers 'CookieResult' => @@cookResult
          headers 'HeaderResult' => @@headResult
          body 'Web Application Firewall Detection Tool'
        end
      
      end
    
    end
  end
end
