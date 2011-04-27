module BeEF
module Extensions

    # Return configuration hashes of all extensions that are enabled
    def self.get_enabled
        return BeEF::Core::Configuration.instance.get('beef.extension').select { |k,v| v['enable'] == true }
    end

    # Return configuration hashes of all extensions that are loaded
    def self.get_loaded
        return BeEF::Core::Configuration.instance.get('beef.extension').select {|k,v| v['loaded'] == true }
    end

    # Loads all enabled extensions
    def self.load
        self.get_enabled.each { |k,v|
            BeEF::Extension.load(k)
        }
    end

end
end

