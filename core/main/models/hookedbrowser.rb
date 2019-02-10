#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  #
  #
  #
  class HookedBrowser
  
    include DataMapper::Resource
  
    storage_names[:default] = 'core_hookedbrowsers'
    
    property :id, Serial
    property :session, Text, :lazy => false
    property :ip, Text, :lazy => false
    property :firstseen, String, :length => 15
    property :lastseen, String, :length => 15
    property :httpheaders, Text, :lazy => false
    # @note the domain originating the hook request
    property :domain, Text, :lazy => false
    property :port, Integer, :default => 80
    property :count, Integer, :lazy => false
    property :has_init, Boolean, :default => false
    property :is_proxy, Boolean, :default => false     
    # @note if true the HB is used as a tunneling proxy

    has n, :commands
    has n, :results
    has n, :logs
    #has n, :https
  
    # Increases the count of a zombie
    def count!
      if not self.count.nil? then self.count += 1; else self.count = 1; end
    end
  end
end
end
end
