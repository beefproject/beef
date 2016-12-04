#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Core
    module AutorunEngine
      module Models
        # @note Table stores the rules for the Distributed Engine.
        class Rule
          include DataMapper::Resource

          storage_names[:default] = 'core_arerules'

          property :id, Serial
          property :name, Text                                       # rule name
          property :author, String                                   # rule author
          property :browser, String, :length => 10                   # browser name
          property :browser_version, String, :length => 15           # browser version
          property :os, String, :length => 10                        # OS name
          property :os_version, String, :length => 15                # OS version
          property :modules, Text                                    # JSON stringyfied representation of the JSON rule for further parsing
          property :execution_order, Text                            # command module execution order
          property :execution_delay, Text                            # command module time delays
          property :chain_mode, String, :length => 40                 # rule chaining mode

          has n, :executions
        end
      end
    end
  end
end
