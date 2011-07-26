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

    # Gets all module options
    def self.get_options(mod)
        begin
            class_name = BeEF::Core::Configuration.instance.get("beef.module.#{mod}.class")
            class_symbol = BeEF::Core::Command.const_get(class_name)
            if class_symbol
              return class_symbol.options
            end
        rescue
          print_debug "Unable to find module class: BeEF::Core::Commands::#{mod.capitalize}"
        end
    end
    
    # Loads module
    def self.load(mod)
        config = BeEF::Core::Configuration.instance
        if File.exists?(config.get('beef.module.'+mod+'.path')+'/module.rb')
            require config.get('beef.module.'+mod+'.path')+'/module.rb'
            BeEF::Core::Configuration.instance.set('beef.module.'+mod+'.class', mod.capitalize)
            if self.exists?(mod)
                BeEF::Core::Configuration.instance.set('beef.module.'+mod+'.loaded', true)
                self.parse_targets(mod)
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

    # Checks target configuration to see if browser / version / operating system is supported
    # Support uses a rating system to provide the most accurate results.
    # 1 = All match. ie: All was defined.
    # 2 = String match. ie: Firefox was defined as working.
    # 3 = Hash match. ie: Firefox defined with 1 additional parameter (eg max_ver).
    # 4+ = As above but with extra parameters.
    # Please note this rating system has no correlation to the return constant value BeEF::Core::Constants::CommandModule::*
    def self.support(mod, opts)
        target_config = BeEF::Core::Configuration.instance.get('beef.module.'+mod+'.target_new')
        if target_config and opts.kind_of? Hash
            if opts.key?('browser')
                results = []
                target_config.each{|k,m|
                    m.each{|v|
                        case v
                            when String
                                if opts['browser'] == v
                                    results << {'rating' => 2, 'const' => k}
                                end
                            when Hash
                                if opts['browser'] == v.keys.first
                                    subv = v[v.keys.first]
                                    rating = 1
                                    #version check
                                    if opts.key?('ver')
                                        if subv.key?('min_ver')
                                            if subv['min_ver'].kind_of? Fixnum and opts['ver'] >= subv['min_ver']
                                                rating += 1
                                            else
                                                break
                                            end
                                        end
                                        if subv.key?('max_ver')
                                            if subv['max_ver'].kind_of? Fixnum and opts['ver'] <= subv['max_ver']
                                                rating += 1
                                            else
                                                break
                                            end
                                        end
                                    end
                                    # os check
                                    if opts.key?('os') and subv.key?('os')
                                        match = false
                                        opts['os'].each{|o|
                                            case subv['os']
                                                when String
                                                    if o == subv['os']
                                                        rating += 1
                                                        match = true
                                                    elsif subv['os'] == BeEF::Core::Constants::Os::OS_ALL_UA_STR
                                                        rating += 1
                                                        match = true
                                                    end
                                                when Array
                                                    subv['os'].each{|p|
                                                        if o == p or p == BeEF::Core::Constants::Os::OS_ALL_UA_STR
                                                            rating += 1
                                                            match = true
                                                        end
                                                    }
                                            end
                                        }
                                        if not match 
                                            break
                                        end
                                    end
                                    if rating != 1
                                        results << {'rating' => rating, 'const' => k}
                                    end
                                end
                        end
                        if v == BeEF::Core::Constants::Browsers::ALL
                            results << {'rating' => 1, 'const' => k}
                        end
                    }
                }
                if results.count > 0
                    return results.sort_by {|v| v['rating']}.last['const']
                else
                    return BeEF::Core::Constants::CommandModule::VERIFIED_UNKNOWN
                end
            else
                print_error "BeEF::Module.support() was passed a hash without a valid browser constant"
            end
        end
        return nil
    end

    # Translates module target configuration
    def self.parse_targets(mod)
        target_config = BeEF::Core::Configuration.instance.get('beef.module.'+mod+'.target')
        if target_config
            targets = {}
            target_config.each{|k,v|
                begin
                    if BeEF::Core::Constants::CommandModule.const_defined?('VERIFIED_'+k.upcase)
                        key = BeEF::Core::Constants::CommandModule.const_get('VERIFIED_'+k.upcase)
                        if not targets.key?(key)
                            targets[key] = []
                        end
                        browser = nil
                        case v
                            when String
                                browser = self.match_target_browser(v)
                                if browser
                                    targets[key] << browser
                                end
                            when Array
                                v.each{|c|
                                    browser = self.match_target_browser(c)
                                    if browser
                                        targets[key] << browser
                                    end
                                }
                            when Hash
                                v.each{|k,c|
                                    browser = self.match_target_browser(k)
                                    if browser
                                        case c
                                            when TrueClass
                                                targets[key] << browser
                                            when Hash
                                                details = self.match_target_browser_spec(c)
                                                if details
                                                    targets[key] << {browser => details}
                                                end
                                        end
                                    end
                                }
                        end
                    end
                rescue NameError
                    print_error "Module \"#{mod}\" configuration has invalid target status defined \"#{k}\""
                end
            }
            BeEF::Core::Configuration.instance.set("beef.module.#{mod}.target_new", targets)
        end
    end

    # Translates simple browser target configuration
    def self.match_target_browser(v)
        browser = false
        if v.class == String
            begin
                if BeEF::Core::Constants::Browsers.const_defined?(v.upcase)
                    browser = BeEF::Core::Constants::Browsers.const_get(v.upcase)
                end
            rescue NameError
                print_error "Could not identify browser target specified as \"#{v}\""
            end
        else
            print_error "Invalid datatype passed to BeEF::Module.match_target_browser()"
        end
        return browser
    end

    # Translates complex browser target configuration
    def self.match_target_browser_spec(v)
        browser = {}
        if v.class == Hash
            if v.key?('max_ver') and (v['max_ver'].is_a?(Fixnum) or v['max_ver'].is_a?(Float))
                browser['max_ver'] = v['max_ver']
            end
            if v.key?('min_ver') and (v['min_ver'].is_a?(Fixnum) or v['min_ver'].is_a?(Float))
                browser['min_ver'] = v['min_ver']
            end
            if v.key?('os')
                case v['os']
                    when String
                        os = self.match_target_os(v['os'])
                        if os 
                            browser['os'] = os 
                        end
                    when Array
                        browser['os'] = []
                        v['os'].each{|c|
                            os = self.match_target_os(c)
                            if os
                                browser['os'] << os 
                            end
                        }
                end
            end
        else
            print_error "Invalid datatype passed to BeEF::Module.match_target_browser_spec()"
        end
        return browser
    end

    # Translates simple OS target configuration
    def self.match_target_os(v)
        os = false
        if v.class == String
            begin
                if BeEF::Core::Constants::Os.const_defined?("OS_#{v.upcase}_UA_STR")
                    os = BeEF::Core::Constants::Os.const_get("OS_#{v.upcase}_UA_STR")
                end
            rescue NameError
                print_error "Could not identify OS target specified as \"#{v}\""
            end
        else
            print_error "Invalid datatype passed to BeEF::Module.match_target_os()"
        end
        return os
    end

end
end


