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
module Core

  # @note This class migrates and updates values in the database each time you restart BeEF.
  #   So for example, when you want to add a new command module, you stop BeEF, copy your command module into the framework
  #   and then restart BeEF. That class will take care of installing automatically the new command module in the db.
  class Migration
  
    include Singleton
  
    # Updates the database.
    def update_db!
      update_commands!
    end
  
    # Checks for new command modules and updates the database.
    def update_commands!
      config = BeEF::Core::Configuration.instance

      db_modules = []
      BeEF::Core::Models::CommandModule.all.each do |mod|
        db_modules << mod.name
      end
      

      config.get('beef.module').each{|k,v|
        BeEF::Core::Models::CommandModule.new(:name => k, :path => "#{v['path']}module.rb").save if not db_modules.include? k
      }
    
      BeEF::Core::Models::CommandModule.all.each{|mod|
        if config.get('beef.module.'+mod.name) != nil
            config.set('beef.module.'+mod.name+'.db.id', mod.id)
            config.set('beef.module.'+mod.name+'.db.path', mod.path)
        end
      }

      # Call Migration method
      BeEF::API::Registrar.instance.fire(BeEF::API::Migration, 'migrate_commands')
      
    end
  end
end
end
