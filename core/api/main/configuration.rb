#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module API
    module Configuration
      # @note Defined API Paths
      API_PATHS = {
        'module_configuration_load' => :module_configuration_load
      }.freeze

      # Fires just after module configuration is loaded and merged
      # @param [String] mod module key
      def module_configuration_load(mod); end
    end
  end
end
