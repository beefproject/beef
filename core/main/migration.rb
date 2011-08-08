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
  #
  # This class migrates and updates values in the database each time you restart BeEF.
  # So for example, when you want to add a new command module, you stop BeEF, copy your command module into the framework
  # and then restart BeEF. That class will take care of installing automatically the new command module in the db.
  #
  class Migration
  
    include Singleton
  
    #
    # Updates the database.
    #
    def update_db!
      update_commands!
    end
  
    #
    # Checks for new command modules and updates the database.
    #
    def update_commands!
      db_commands = [], folders = ''
      config = BeEF::Core::Configuration.instance
    
      BeEF::Core::Models::CommandModule.all.each {|db_command| 
        db_commands.push(db_command.path)
      }
    
      Dir.foreach("#{$root_dir}/modules/") do |folder|
        folders += "#{folder}|" if not ['.', '..'].include? folder and File.directory? "#{$root_dir}/modules/#{folder}"
      end
    
      regex = /\/modules\/(#{folders})\/(.*).rb/i
    
      Dir["#{$root_dir}/modules/**/*.rb"].each do |command|
        if (command = command.match(regex)[0])
            name = ''
            path = command.split(File::SEPARATOR).reverse
            if path.size >= 1
                name = path[1].to_s
            end
            BeEF::Core::Models::CommandModule.new(:name => name, :path => command).save if not db_commands.include? command
        end
      end

      BeEF::Core::Models::CommandModule.all.each{|mod|
        if config.get('beef.module.'+mod.name) != nil
            config.set('beef.module.'+mod.name+'.db.id', mod.id)
            config.set('beef.module.'+mod.name+'.db.path', mod.path)
        end
      }

      # Call Migration method
      BeEF::API.fire(BeEF::API::Migration, 'migrate_commands')
      
    end
  end
end
end
