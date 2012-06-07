#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
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
  module Modules

    # Return configuration hashes of all modules that are enabled
    # @return [Array] configuration hashes of all enabled modules
    def self.get_enabled
      return BeEF::Core::Configuration.instance.get('beef.module').select {|k,v| v['enable'] == true and v['category'] != nil }
    end

    # Return configuration hashes of all modules that are loaded
    # @return [Array] configuration hashes of all loaded modules
    def self.get_loaded
      return BeEF::Core::Configuration.instance.get('beef.module').select {|k,v| v['loaded'] == true }
    end

    # Return an array of categories specified in module configuration files
    # @return [Array] all available module categories sorted alphabetically
    def self.get_categories
      categories = []
      BeEF::Core::Configuration.instance.get('beef.module').each {|k,v|
        flatcategory = ""
        if v['category'].kind_of?(Array)
          # Therefore this module has nested categories (sub-folders), munge them together into a string with '/' characters, like a folder.
          v['category'].each {|cat|
            flatcategory << cat + "/"
          }
        else
          flatcategory = v['category']
        end
        if not categories.include?(flatcategory)
          categories << flatcategory
        end
      }
      return categories.sort.uniq #This is now uniqued, because otherwise the recursive function to build the json tree breaks if there are duplicates.
    end

    # Get all modules currently stored in the database
    # @return [Array] DataMapper array of all BeEF::Core::Models::CommandModule's in the database
    def self.get_stored_in_db
      return BeEF::Core::Models::CommandModule.all(:order => [:id.asc])
    end

    # Loads all enabled modules 
    # @note API Fire: post_soft_load
    def self.load
      BeEF::Core::Configuration.instance.load_modules_config
      self.get_enabled.each { |k,v|
        BeEF::Module.soft_load(k)
      }
      BeEF::API::Registrar.instance.fire(BeEF::API::Modules, 'post_soft_load')
    end
  end
end
