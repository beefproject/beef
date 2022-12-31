#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      class HookedBrowser < BeEF::Core::Model
        has_many :commands
        has_many :results
        has_many :logs

        # @note Increases the count of a zombie
        def count!
          count.nil? ? self.count = 1 : self.count += 1
        end
      end
    end
  end
end
