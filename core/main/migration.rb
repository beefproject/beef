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
    
      BeEF::Core::Models::CommandModule.all.each {|db_command| 
        db_commands.push(db_command.path)
      }
    
      Dir.foreach("#{$root_dir}/modules/") do |folder|
        folders += "#{folder}|" if not ['.', '..'].include? folder and File.directory? "#{$root_dir}/modules/#{folder}"
      end
    
      regex = /\/modules\/(#{folders})\/(.*).rb/i
    
      Dir["#{$root_dir}/modules/**/*.rb"].each do |command|
        if (command = command.match(regex)[0])
          BeEF::Core::Models::CommandModule.new(:path => command, :name => /.*\/(\w+)\.rb/.match(command).to_a[1]).save if not db_commands.include? command
        end
      end
      
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
