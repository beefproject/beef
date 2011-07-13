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
module Module 

    # Checks to see if module is in configuration
    def self.is_present(mod)
        return BeEF::Core::Configuration.instance.get('beef.module').has_key?(mod.to_s)
    end

    # Checks to see if module is enabled in configuration
    def self.is_enabled(mod)
        return (self.is_present(mod) and BeEF::Core::Configuration.instance.get('beef.module.'+mod.to_s+'.enable') == true)
    end

    # Checks to see if the module reports that it has loaded through the configuration
    def self.is_loaded(mod)
        return (self.is_enabled(mod) and BeEF::Core::Configuration.instance.get('beef.module.'+mod.to_s+'.loaded') == true)
    end

    # Loads module
    def self.load(mod)
        config = BeEF::Core::Configuration.instance
        if File.exists?(config.get('beef.module.'+mod+'.path')+'/module.rb')
            require config.get('beef.module.'+mod+'.path')+'/module.rb'
            BeEF::Core::Configuration.instance.set('beef.module.'+mod+'.class', mod.capitalize)
            if self.exists?(mod)
                BeEF::Core::Configuration.instance.set('beef.module.'+mod+'.loaded', true)
                print_debug "Loaded module: '#{mod}'"
                return true
            else
                BeEF::Core::Configuration.instance.set('beef.module.'+mod+'.loaded', false)
                print_debug "Unable to locate module class: BeEF::Core::Commands::#{mod.capitalize}"
            end
        else
            print_debug "Unable to locate module file: #{config.get('beef.module.'+mod+'.path')}module.rb"
        end
        print_error "Unable to load module '#{mod}'"
        return false
    end
    
    # Return module key by database id
    def self.get_key_by_database_id(id)
        ret = BeEF::Core::Configuration.instance.get('beef.module').select {|k, v| v.has_key?('db') and v['db']['id'].to_i == id.to_i }
        return (ret.kind_of?(Array)) ? ret.first.first : ret.keys.first
    end

    #checks to see if module class exists
    def self.exists?(mod)
        begin
            kclass = BeEF::Core::Command.const_get(mod.capitalize)
            return kclass.is_a?(Class)
        rescue NameError
            return false
        end
    end
end
end


