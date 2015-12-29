#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Core
    module AutorunEngine
      module Models
        # @note Stored info about the execution of the ARE on hooked browsers.
        class Execution

          include DataMapper::Resource

          storage_names[:default] = 'core_areexecution'

          property :id, Serial
          property :session, Text                         # hooked browser session where a ruleset triggered
          property :mod_count, Integer                    # number of command modules of the ruleset
          property :mod_successful, Integer               # number of command modules that returned with success
          # By default Text is only 65K, so field length increased to 1 MB
          property :mod_body, Text,    :length => 1024000 # entire command module(s) body to be sent
          property :exec_time, String, :length => 15      # timestamp of ruleset triggering
          property :is_sent, Boolean
        end
      end
    end
  end
end
