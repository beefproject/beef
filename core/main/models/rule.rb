#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Core
    module Models
      # @note Table stores the rules for the Distributed Engine.
      class Rule < BeEF::Core::Model
        has_many :executions
      end
    end
  end
end
