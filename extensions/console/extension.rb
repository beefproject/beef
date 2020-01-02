#
# Copyright (c) 2006-2020 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Console

  extend BeEF::API::Extension
  
  #
  # Sets the information for that extension.
  #
  @short_name = @full_name = 'console'
  @description = 'console environment to manage beef'

  module PostLoad
    BeEF::API::Registrar.instance.register(BeEF::Extension::Console::PostLoad, BeEF::API::Extensions, 'post_load')

    def self.post_load
      if BeEF::Core::Configuration.instance.get("beef.extension.console.enable")
        print_error "The console extension is currently unsupported."
        print_more "See issue #1090 - https://github.com/beefproject/beef/issues/1090"
        BeEF::Core::Configuration.instance.set('beef.extension.console.enable', false)
        BeEF::Core::Configuration.instance.set('beef.extension.console.loaded', false)
      end
    end
  end
end
end
end

