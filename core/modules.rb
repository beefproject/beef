module BeEF
module Modules

    # Return configuration hashes of all modules that are enabled
    def self.get_enabled
        return BeEF::Core::Configuration.instance.get('beef.module').select {|k,v| v['enable'] == true and v['category'] != nil }
    end

    # Return configuration hashes of all modules that are loaded
    def self.get_loaded
        return BeEF::Core::Configuration.instance.get('beef.module').select {|k,v| v['loaded'] == true }
    end

    # Loads modules 
    def self.load
        self.get_enabled.each { |k,v|
            BeEF::Module.load(k, v['category'])
        }
    end
end
end
