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

    # @note zombie ID
    property :id, Serial

    # @note hooked browser session ID
    property :session, Text, :lazy => false

    # @note IP address of the hooked browser
    property :ip, Text, :lazy => false

    # @note timestamp first time the browser communicated with BeEF
    property :firstseen, String, :length => 15

    # @note timestamp last time the browser communicated with BeEF
    property :lastseen, String, :length => 15

    # @note HTTP headers sent be the browser to the BeEF server upon first hook
    property :httpheaders, Text, :lazy => false

    # @note the domain originating the hook request
    property :domain, Text, :lazy => false

    # @note the port on the domain originating the hook request
    property :port, Integer, :default => 80

    # @note number of times the zombie has polled
    property :count, Integer, :lazy => false

    # @note if true the HB is used as a tunneling proxy
    property :is_proxy, Boolean, :default => false

    has n, :commands
    has n, :results
    has n, :logs
  
    # @note Increases the count of a zombie
    def count!
      if not self.count.nil? then self.count += 1; else self.count = 1; end
    end
  end
end
end
end
