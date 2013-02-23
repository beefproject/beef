#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module NetworkStack
      module Handlers

        class Raw

	        def initialize(status, header={}, body)
	        	@status  = status
	                @header  = header
	                @body    = body
	        end

	        def call(env)
	            [@status, @header, @body]
	        end

	        private

	        @request

	        @response

	    end
	end
end
end
end
