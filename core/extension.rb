module BeEF
module Extension

    # Checks to see if extensions is in configuration
    def self.is_present(ext)
        return BeEF::Core::Configuration.instance.get('beef.extension').has_key?(ext.to_s)
    end

    # Checks to see if extension is enabled in configuration
    def self.is_enabled(ext)
        return (self.is_present(ext) and BeEF::Core::Configuration.instance.get('beef.extension.'+ext.to_s+'.enable') == true)
    end

    # Checks to see if extensions reports loaded through the configuration
    def self.is_loaded(ext)
        return (self.is_enabled(ext) and BeEF::Core::Configuration.instance.get('beef.extension.'+ext.to_s+'.loaded') == true)
    end

    # Loads extension 
    def self.load(ext)
        if File.exists?('extensions/'+ext+'/extension.rb')
            require 'extensions/'+ext+'/extension.rb'
            print_debug "Loaded extension: '#{ext}'"
            BeEF::Core::Configuration.instance.set('beef.extension.'+ext+'.loaded', true)
            return true
        end 
        print_error "Unable to load extension '#{ext}'"
        return false
    end
end
end
