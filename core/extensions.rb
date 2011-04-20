module BeEF
module Extension

end
end

# Include only enabled extensions
config = BeEF::Core::Configuration.instance
extensions = config.get('beef.extension').select{|key, ext|
    ext['enable'] == true
}

extensions.each{ |k,v|
    if File.exists?('extensions/'+k+'/extension.rb')
        require 'extensions/'+k+'/extension.rb'
    end
}
