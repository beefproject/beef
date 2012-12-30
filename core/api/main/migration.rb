#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module API
  module Migration
    
    # @note Defined API Paths
    API_PATHS = {
        'migrate_commands' => :migrate_commands
    }

    # Fired just after the migration process
    def migrate_commands; end
    
  end
  
end
end
