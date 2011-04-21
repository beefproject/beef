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
      
      # We use the API to execute the migration code for each extensions that needs it.
      # For example, the metasploit extensions requires to add new commands into the database.
      BeEF::API::Migration.extended_in_modules.each do |mod|
        begin
          mod.migrate_commands!
        rescue Exception => e
          puts e.message  
          puts e.backtrace
        end
      end
    end
  end
end
end
