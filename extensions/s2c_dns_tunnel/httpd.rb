module BeEF
  module Extension
    module ServerClientDnsTunnel

      class Httpd < Sinatra::Base

        def initialize(domain)
          super()
          @domain = domain
        end

        get "/map" do
          if request.host.match("^_ldap\._tcp\.[0-9a-z\-]+\.domains\._msdcs\.#{@domain}$")
            path = File.dirname(__FILE__)
            send_file File.join(path, 'pixel.jpg')
          end
        end
      end

    end
  end
end

require 'sinatra/base'
