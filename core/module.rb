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
    
    # Returns category name in a system folder format
    def self.safe_category(cat)
        return cat.to_s.strip.downcase.sub(/\s/, '_')
    end
end
end


