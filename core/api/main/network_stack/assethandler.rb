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
module API
module NetworkStack
module Handlers
module AssetHandler

    # Binds a file to be accessible by the hooked browser
    # @param [String] file file to be served
    # @param [String] path URL path to be bound, if no path is specified a randomly generated one will be used
    # @param [String] extension to be used in the URL
    # @param [Integer] count amount of times the file can be accessed before being automatically unbound. (-1 = no limit)
    # @return [String] URL bound to the specified file
    # @todo Add hooked browser parameter to only allow specified hooked browsers access to the bound URL. Waiting on Issue #336
    # @note This is a direct API call and does not have to be registered to be used
    def self.bind(file, path=nil, extension=nil, count=-1)
        return BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind(file, path, extension, count)
    end

    # Unbinds a file made accessible to hooked browsers
    # @param [String] url the bound URL
    # @todo Add hooked browser parameter to only unbind specified hooked browsers binds. Waiting on Issue #336
    # @note This is a direct API call and does not have to be registered to be used
    def self.unbind(url)
        BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind(url)
    end

end
end
end
end
end
