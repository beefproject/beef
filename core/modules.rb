module BeEF
module Module 

    def self.safe_category(cat)
        return cat.to_s.strip.downcase.sub(/\s/, '_')
    end

    def self.loaded
        config = BeEF::Core::Configuration.instance
        return config.get('beef.module').select{|v| v.has_key?('loaded') and v['loaded'] == true }
    end

end
end

# Include only enabled modules 
config = BeEF::Core::Configuration.instance
modules = config.get('beef.module').select{|key, mod|
    mod['enable'] == true and mod['category'] != nil
}

modules.each{ |k,v|
    cat = BeEF::Module.safe_category(v['category'])
    if File.exists?('modules/'+cat+'/'+k+'/module.rb')
        require 'modules/'+cat+'/'+k+'/module.rb'
        config.set('beef.module.'+k+'.loaded', true)
    end
}
