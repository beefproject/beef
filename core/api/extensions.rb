#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module API
    module Extensions

      # @note Defined API Paths
      API_PATHS = {
          'post_load' => :post_load
      }

      # API hook fired after all extensions have been loaded
      def post_load;
      end

    end
  end
end
