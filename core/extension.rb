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

end
end
