#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module HBManager
    # Get hooked browser by session id
    # @param [String] sid hooked browser session id string
    # @return [BeEF::Core::Models::HookedBrowser] returns the associated Hooked Browser
    def self.get_by_session(sid)
      BeEF::Core::Models::HookedBrowser.where(session: sid).first
    end

    # Get hooked browser by id
    # @param [Integer] id hooked browser database id
    # @return [BeEF::Core::Models::HookedBrowser] returns the associated Hooked Browser
    def self.get_by_id(id)
      BeEF::Core::Models::HookedBrowser.find(id)
    end
  end
end
