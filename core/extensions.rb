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
module Extensions

    # Returns configuration of all enabled extensions
    # @return [Array] an array of extension configuration hashes that are enabled
    def self.get_enabled
        return BeEF::Core::Configuration.instance.get('beef.extension').select { |k,v| v['enable'] == true }
    end

    # Returns configuration of all loaded extensions
    # @return [Array] an array of extension configuration hashes that are loaded
    def self.get_loaded
        return BeEF::Core::Configuration.instance.get('beef.extension').select {|k,v| v['loaded'] == true }
    end

    # Load all enabled extensions
    # @note API fire for post_load
    def self.load
        BeEF::Core::Configuration.instance.load_extensions_config
        self.get_enabled.each { |k,v|
            BeEF::Extension.load(k)
        }
        # API post extension load
        BeEF::API::Registrar.instance.fire(BeEF::API::Extensions, 'post_load')
    end

end
end

