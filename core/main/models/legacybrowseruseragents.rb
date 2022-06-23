#
# Copyright (c) 2006-2022 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      #
      # Objects stores known 'legacy' browser User Agents.
      #
      # This table is used to determine if a hooked browser is a 'legacy' 
      # browser and therefore which version of the hook file to generate and use
      #
      # TODO: make it an actual table
      #
      module LegacyBrowserUserAgents
        def self.user_agents
          [
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:100.0) Gecko/20100101 Firefox/100.0'
          ]
        end
      end
    end
  end
end
