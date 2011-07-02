#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
module BeEF
module Extension
module Proxy

  class HttpProxyBase < WEBrick::HTTPProxyServer

    # call BeEF::HttpProxyZombie.instance
    include Singleton

    attr_reader :config
    
    def initialize
      @configuration = BeEF::Core::Configuration.instance
      @config[:Logger] = WEBrick::Log.new($stdout, WEBrick::Log::ERROR)
      @config[:ServerType] = Thread
      super(@config)
    end

    # remove beef hook if it exists
    def remove_hook(res)
      print_debug "[PROXY] Removing beef hook from page if present"
      res.body.gsub!(%r'<script.*?http.*?exploit.js.*?</script>', '')
    end
  end

end
end
end
