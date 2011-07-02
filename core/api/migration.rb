#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
module BeEF
module API
  #
  # All modules that extend the Migration module will be called during the database
  # migration phase of BeEF.
  #
  # So if you are developing an extension that requires injecting new commands into
  # the database. You will want to use that.
  #
  # See the Metasploit extension for example.
  #
  #  Example:
  #
  #     module A
  #       extend BeEF::API::Migration
  #     end
  #
  #
  # BeEF Core then calls all the migration modules like this:
  #
  #   BeEF::API::Migration.extended_in_modules.each do |mod|
  #     ...
  #   end
  #
  module Migration
    
    #
    # This function gets called by the core when migrating new commands into the framework.
    # For example, the metasploit examples needs to store the list of exploits into BeEF's
    # database.
    #
    def migrate_commands!; end
    
  end
  
end
end