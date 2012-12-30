#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module HBManager

    # Get hooked browser by session id
    # @param [String] sid hooked browser session id string
    # @return [BeEF::Core::Models::HookedBrowser] returns the associated Hooked Browser
    def self.get_by_session(sid)
      BeEF::Core::Models::HookedBrowser.first(:session => sid)
    end

    # Get hooked browser by id
    # @param [Integer] id hooked browser database id
    # @return [BeEF::Core::Models::HookedBrowser] returns the associated Hooked Browser
    def self.get_by_id(id)
      BeEF::Core::Models::HookedBrowser.first(:id => id)
    end

  end
end
