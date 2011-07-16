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
module Module 

    # Checks to see if module is in configuration
    def self.is_present(mod)
        return BeEF::Core::Configuration.instance.get('beef.module').has_key?(mod.to_s)
    end

    # Checks to see if module is enabled in configuration
    def self.is_enabled(mod)
        return (self.is_present(mod) and BeEF::Core::Configuration.instance.get('beef.module.'+mod.to_s+'.enable') == true)
    end

    # Checks to see if the module reports that it has loaded through the configuration
    def self.is_loaded(mod)
        return (self.is_enabled(mod) and BeEF::Core::Configuration.instance.get('beef.module.'+mod.to_s+'.loaded') == true)
    end

    # Loads module
    def self.load(mod)
        config = BeEF::Core::Configuration.instance
        if File.exists?(config.get('beef.module.'+mod+'.path')+'/module.rb')
            require config.get('beef.module.'+mod+'.path')+'/module.rb'
            BeEF::Core::Configuration.instance.set('beef.module.'+mod+'.class', mod.capitalize)
            if self.exists?(mod)
                BeEF::Core::Configuration.instance.set('beef.module.'+mod+'.loaded', true)
                print_debug "Loaded module: '#{mod}'"
                return true
            else
                BeEF::Core::Configuration.instance.set('beef.module.'+mod+'.loaded', false)
                print_debug "Unable to locate module class: BeEF::Core::Commands::#{mod.capitalize}"
            end
        else
            print_debug "Unable to locate module file: #{config.get('beef.module.'+mod+'.path')}module.rb"
        end
        print_error "Unable to load module '#{mod}'"
        return false
    end
    
    # Return module key by database id
    def self.get_key_by_database_id(id)
        ret = BeEF::Core::Configuration.instance.get('beef.module').select {|k, v| v.has_key?('db') and v['db']['id'].to_i == id.to_i }
        return (ret.kind_of?(Array)) ? ret.first.first : ret.keys.first
    end

    #checks to see if module class exists
    def self.exists?(mod)
        begin
            kclass = BeEF::Core::Command.const_get(mod.capitalize)
            return kclass.is_a?(Class)
        rescue NameError
            return false
        end
    end

    # Translates module target configuration
    def self.parse_targets(mod)
        target_config = BeEF::Core::Configuration.instance.get('beef.module.'+mod+'.target')
        if target_config
            targets = {}
            target_config.each{|k,v|
                if BeEF::Core::Constants::CommandModule.const_defined?('VERIFIED_'+k.upcase)
                    key = BeEF::Core::Constants::CommandModule.const_get('VERIFIED_'+k.upcase)
                    if not targets.key?(key)
                        targets[key] = []
                    end
                    targets[key] << self.parse_target_browsers(v)
                else
                    print_debug "Module \"#{mod}\" configuration has invalid target status defined \"#{k}\""
                end

            }
        end
        puts targets
    end

    # Translates browser target configuration
    # TODO: problems, once yaml merges duplicate keys, the item can either be an array or hash. What happens if there is a hash inside of the array
    def self.parse_target_browsers(v)
        browser = nil
        case v
            when String
                if BeEF::Core::Constants::Browsers.const_defined?(v.upcase)
                    browser = BeEF::Core::Constants::Browsers.const_get(v.upcase)
                end
            when Array
                v.each{|c|
                    if BeEF::Core::Constants::Browsers.const_defined?(c.upcase)
                        if browser == nil
                            browser = []
                        end
                        browser << self.parse_target_browsers(c)
                    end
                }
            when Hash
               return 
                if BeEF::Core::Constants::Browsers.const_defined?(v.upcase)
                    details = {}
                    if v.key?('max_ver') and (v['max_ver'].is_a(Fixnum) or v['max_ver'].is_a(Float))
                        details['max_ver'] = v['max_ver']
                    end
                    if v.key?('min_ver') and (v['min_ver'].is_a(Fixnum) or v['min_ver'].is_a(Float))
                        details['min_ver'] = v['min_ver']
                    end
                    if v.key?('os')
                        if v['os'].is_a(String)
                            if BeEF::Core::Constants::Os.const_defined?('OS_'+v['os'].upcase+'_UA_STR')
                                details['os'] = [BeEF::Core::Constants::Os.const_get('OS_'+v['os'].upcase+'_UA_STR')]
                            else
                                print_debug "Could not identify OS target specified in module \"#{mod}\" configuration"
                            end
                        else v['os'].is_a(Array)
                            v['os'].each{|o|
                                if BeEF::Core::Constants::Os.const_defined?('OS_'+o.upcase+'_UA_STR')
                                    details['os'] = [BeEF::Core::Constants::Os.const_get('OS_'+o.upcase+'_UA_STR')]
                                else
                                    print_debug "Could not identify OS target specified in module \"#{mod}\" configuration"
                                end
                            }
                        end
                    end
                    targets[key] << BeEF::Core::Constants::Browers.const_get(v.upcase)
                    targets[key][BeEF::Core::Constants::Browers.const_get(v.upcase)] = details
                else
                    print_debug "Could not identify browser target specified in module \"#{mod}\" configuration"
                end
            else
                print_debug "Module \"#{mod}\" configuration has invalid target definition"
        end

        if not browser
            print_debug "Could not identify browser target specified in module \"#{mod}\" configuration"
            return
        end
        browser
    end

end
end


