#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      class Result < BeEF::Core::Model
        has_one :command
        has_one :hooked_browser
      end
    end
  end
end
