#
# Include here all the gems we are using
#
require 'rubygems'
require 'webrick'
require 'webrick/httpproxy'
require 'dm-core'
require 'dm-migrations'
require 'json'
require 'ansi'
require 'optparse'
require 'cgi'
require 'yaml'
require 'singleton'
require 'ipaddr'
require 'base64'
require 'xmlrpc/client'
require 'erubis'
require 'openssl'
require 'term/ansicolor'

# Include the filters
require 'core/filters'

# Include our patches for ruby and gems
require 'core/ruby'

# Include the API
require 'core/api'

# Include the settings
require 'core/settings'

# Include the core of BeEF
require 'core/core'

# Include helpers
require 'core/module'
require 'core/modules'
require 'core/extension'
require 'core/extensions'

config = BeEF::Core::Configuration.instance

# Include extensions defined in the Configuration
extensions = config.get('beef.extension').select{|key, ext| ext['enable'] == true }
extensions.each{ |k,v|
    if File.exists?('extensions/'+k+'/extension.rb')
        require 'extensions/'+k+'/extension.rb'
    end
}

# Include modules defined in the Configuration
modules = config.get('beef.module').select{|key, mod| mod['enable'] == true and mod['category'] != nil }
modules.each{ |k,v|
    cat = BeEF::Module.safe_category(v['category'])
    if File.exists?('modules/'+cat+'/'+k+'/module.rb')
        require 'modules/'+cat+'/'+k+'/module.rb'
        config.set('beef.module.'+k+'.loaded', true)
    end
}
