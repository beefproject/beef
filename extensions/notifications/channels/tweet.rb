#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
#
#
require 'twitter'

module BeEF
module Extension
module Notifications
module Channels
  
  class Tweet

    #
    # Constructor
    #
    def initialize(username, message)
      @config = BeEF::Core::Configuration.instance

      # configure the Twitter client
      Twitter.configure do |config|
        config.consumer_key       = @config.get('beef.extension.notifications.twitter.consumer_key')
        config.consumer_secret    = @config.get('beef.extension.notifications.twitter.consumer_secret')
        config.oauth_token    = @config.get('beef.extension.notifications.twitter.oauth_token')
        config.oauth_token_secret = @config.get('beef.extension.notifications.twitter.oauth_token_secret')
      end

      begin
        Twitter.direct_message_create(username, message)
      rescue
        print "Twitter send failed, verify tokens have Read/Write/DM acceess..\n"
      end
    end
  end
  
end
end
end
end

