#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
