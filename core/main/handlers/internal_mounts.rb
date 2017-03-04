#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Handlers
      class InternalMounts
        include Singleton

        def initialize
          @internal_mount_points = {
              '/init' => BeEF::Core::Handlers::BrowserDetails,
              '/hook.js' => BeEF::Core::Handlers::HookedBrowsers,
              '/event' => BeEF::Core::Handlers::Events
          }
        end

        def add_mountpoint(path , klass)
          @internal_mount_points[path] = klass
        end

        def get_mountpoints
          @internal_mount_points
        end

      end


    end
  end
end