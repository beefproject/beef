#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module ETag
module API

  module ETagHandler
    BeEF::API::Registrar.instance.register(
            BeEF::Extension::ETag::API::ETagHandler,
            BeEF::API::Server,
            'mount_handler'
    )

    def self.mount_handler(beef_server)
        beef_server.mount('/etag', BeEF::Extension::ETag::ETagWebServer.new!)
        print_info "ETag Server: /etag" 
    end

  end

end
end
end
end
