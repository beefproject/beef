#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Modules
    # Return configuration hashes of all modules that are enabled
    # @return [Array] configuration hashes of all enabled modules
    def self.get_enabled
      BeEF::Core::Configuration.instance.get('beef.module').select do |_k, v|
        v['enable'] == true && !v['category'].nil?
      end
    end

    # Return configuration hashes of all modules that are loaded
    # @return [Array] configuration hashes of all loaded modules
    def self.get_loaded
      BeEF::Core::Configuration.instance.get('beef.module').select do |_k, v|
        v['loaded'] == true
      end
    end

    # Return an array of categories specified in module configuration files
    # @return [Array] all available module categories sorted alphabetically
    def self.get_categories
      categories = []
      BeEF::Core::Configuration.instance.get('beef.module').each_value do |v|
        flatcategory = ''
        if v['category'].is_a?(Array)
          # Therefore this module has nested categories (sub-folders),
          # munge them together into a string with '/' characters, like a folder.
          v['category'].each do |cat|
            flatcategory << "#{cat}/"
          end
        else
          flatcategory = v['category']
        end
        categories << flatcategory unless categories.include? flatcategory
      end

      # This is now uniqued, because otherwise the recursive function to build
      # the json tree breaks if there are duplicates.
      categories.sort.uniq
    end

    # Get all modules currently stored in the database
    # @return [Array] DataMapper array of all BeEF::Core::Models::CommandModule's in the database
    def self.get_stored_in_db
      BeEF::Core::Models::CommandModule.all.order(:id)
    end

    # Loads all enabled modules
    # @note API Fire: post_soft_load
    def self.load
      BeEF::Core::Configuration.instance.load_modules_config
      get_enabled.each_key do |k|
        BeEF::Module.soft_load k
      end
      BeEF::API::Registrar.instance.fire BeEF::API::Modules, 'post_soft_load'
    end
  end
end
