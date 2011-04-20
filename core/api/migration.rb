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