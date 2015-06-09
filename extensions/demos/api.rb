#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Demos

  module RegisterHttpHandlers

    BeEF::API::Registrar.instance.register(BeEF::Extension::Demos::RegisterHttpHandlers, BeEF::API::Server, 'mount_handler')

    def self.mount_handler(beef_server)
      # mount everything in html directory to /demos/
      path = File.dirname(__FILE__)+'/html/'
      files = Dir[path+'**/*']

      beef_server.mount('/demos', Rack::File.new(path))

      files.each do |f|
        # don't follow symlinks
        next if File.symlink?(f)
        mount_path = '/demos/'+f.sub(path,'')
        if File.extname(f) == '.html'
          # use handler to mount HTML templates
          beef_server.mount(mount_path, BeEF::Extension::Demos::Handler.new(f))
        end
      end
    end
  end
end
end
end
