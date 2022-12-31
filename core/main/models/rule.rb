#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
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
