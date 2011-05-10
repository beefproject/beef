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
    def self.load(mod, cat)
        cat = self.safe_category(cat)
        if File.exists?('modules/'+cat+'/'+mod+'/module.rb')
            require 'modules/'+cat+'/'+mod+'/module.rb'
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
            print_debug "Unable to locate module file: modules/#{cat}/#{mod}/module.rb"
        end
        print_error "Unable to load module '#{mod}'"
        return false
    end
    
    # Return module key by database id
    def self.get_key_by_database_id(id)
        ret = BeEF::Core::Configuration.instance.get('beef.module').select {|k, v| v.has_key?('db') and v['db']['id'].to_i == id.to_i }
        return (ret.kind_of?(Array)) ? ret.first.first : ret.keys.first
    end

    # Returns category name in a system folder format
    def self.safe_category(cat)
        return cat.to_s.strip.downcase.sub(/\s/, '_')
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


