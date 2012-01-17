#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
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
  module HBManager

    # Get hooked browser by session id
    # @param [String] sid hooked browser session id string
    # @return [BeEF::Core::Models::HookedBrowser] returns the associated Hooked Browser
    def self.get_by_session(sid)
      BeEF::Core::Models::HookedBrowser.first(:session => sid)
    end

    # Get hooked browser by id
    # @param [Integer] id hooked browser database id
    # @return [BeEF::Core::Models::HookedBrowser] returns the associated Hooked Browser
    def self.get_by_id(id)
      BeEF::Core::Models::HookedBrowser.first(:id => id)
    end

  end
end
