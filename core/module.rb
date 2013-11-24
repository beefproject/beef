#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Module

    # Checks to see if module key is in configuration
    # @param [String] mod module key
    # @return [Boolean] if the module key exists in BeEF's configuration
    def self.is_present(mod)
      return BeEF::Core::Configuration.instance.get('beef.module').has_key?(mod.to_s)
    end

    # Checks to see if module is enabled in configuration
    # @param [String] mod module key
    # @return [Boolean] if the module key is enabled in BeEF's configuration
    def self.is_enabled(mod)
      return (self.is_present(mod) and BeEF::Core::Configuration.instance.get('beef.module.'+mod.to_s+'.enable') == true)
    end

    # Checks to see if the module reports that it has loaded through the configuration
    # @param [String] mod module key
    # @return [Boolean] if the module key is loaded in BeEF's configuration
    def self.is_loaded(mod)
      return (self.is_enabled(mod) and BeEF::Core::Configuration.instance.get('beef.module.'+mod.to_s+'.loaded') == true)
    end

    # Returns module class definition
    # @param [String] mod module key
    # @return [Class] the module class
    def self.get_definition(mod)
      return BeEF::Core::Command.const_get(BeEF::Core::Configuration.instance.get("beef.module.#{mod.to_s}.class"))
    end

    # Gets all module options
    # @param [String] mod module key
    # @return [Hash] a hash of all the module options
    # @note API Fire: get_options 
    def self.get_options(mod)
      if BeEF::API::Registrar.instance.matched?(BeEF::API::Module, 'get_options', [mod])
        options = BeEF::API::Registrar.instance.fire(BeEF::API::Module, 'get_options', mod)
        mo = []
        options.each{|o|
          if o[:data].kind_of?(Array)
            mo += o[:data]
          else
            print_debug "API Warning: return result for BeEF::Module.get_options() was not an array."
          end
        }
        return mo
      end
      if self.check_hard_load(mod)
        class_name = BeEF::Core::Configuration.instance.get("beef.module.#{mod}.class")
        class_symbol = BeEF::Core::Command.const_get(class_name)
        if class_symbol and class_symbol.respond_to?(:options)
          return class_symbol.options
        end
      end
      return []
    end

    # Gets all module payload options
    # @param [String] mod module key
    # @return [Hash] a hash of all the module options
    # @note API Fire: get_options 
    def self.get_payload_options(mod,payload)
      if BeEF::API::Registrar.instance.matched?(BeEF::API::Module, 'get_payload_options', [mod,nil])
        options = BeEF::API::Registrar.instance.fire(BeEF::API::Module, 'get_payload_options', mod,payload)
        return options
      end
      return []
    end

    # Soft loads a module
    # @note A soft load consists of only loading the modules configuration (ie not the module.rb)
    # @param [String] mod module key
    # @return [Boolean] whether or not the soft load process was successful
    # @note API Fire: pre_soft_load
    # @note API Fire: post_soft_load
    def self.soft_load(mod)
      # API call for pre-soft-load module
      BeEF::API::Registrar.instance.fire(BeEF::API::Module, 'pre_soft_load', mod)
      config = BeEF::Core::Configuration.instance
      if not config.get("beef.module.#{mod}.loaded")
        if File.exists?($root_dir+"/"+config.get('beef.module.'+mod+'.path')+'/module.rb')
          BeEF::Core::Configuration.instance.set('beef.module.'+mod+'.class', mod.capitalize)
          self.parse_targets(mod)
          print_debug "Soft Load module: '#{mod}'"
          # API call for post-soft-load module
          BeEF::API::Registrar.instance.fire(BeEF::API::Module, 'post_soft_load', mod)
          return true
        else
          print_debug "Unable to locate module file: #{config.get('beef.module.'+mod+'.path')}module.rb"
        end
        print_error "Unable to load module '#{mod}'"
      end
      return false
    end

    # Hard loads a module
    # @note A hard load consists of loading a pre-soft-loaded module by requiring the module.rb
    # @param [String] mod module key
    # @return [Boolean] whether or not the hard load was successful
    # @note API Fire: pre_hard_load
    # @note API Fire: post_hard_load
    def self.hard_load(mod)
      # API call for pre-hard-load module
      BeEF::API::Registrar.instance.fire(BeEF::API::Module, 'pre_hard_load', mod)
      config = BeEF::Core::Configuration.instance
      if self.is_enabled(mod)
        begin
          require config.get("beef.module.#{mod}.path")+'module.rb'
          if self.exists?(config.get("beef.module.#{mod}.class"))
            # start server mount point
            BeEF::Core::Server.instance.mount("/command/#{mod}.js", BeEF::Core::Handlers::Commands, mod)
            BeEF::Core::Configuration.instance.set("beef.module.#{mod}.mount", "/command/#{mod}.js")
            BeEF::Core::Configuration.instance.set('beef.module.'+mod+'.loaded', true)
            print_debug "Hard Load module: '#{mod.to_s}'"
            # API call for post-hard-load module
            BeEF::API::Registrar.instance.fire(BeEF::API::Module, 'post_hard_load', mod)
            return true
          else
            print_error "Hard loaded module '#{mod.to_s}' but the class BeEF::Core::Commands::#{mod.capitalize} does not exist"
          end
        rescue => e
          BeEF::Core::Configuration.instance.set('beef.module.'+mod+'.loaded', false)
          print_error "There was a problem loading the module '#{mod.to_s}'"
          print_debug "Hard load module syntax error: #{e.to_s}"
        end
      else
        print_error "Hard load attempted on module '#{mod.to_s}' that is not enabled."
      end
      return false
    end

    # Checks to see if a module has been hard loaded, if not a hard load is attempted
    # @param [String] mod module key
    # @return [Boolean] if already hard loaded then true otherwise (see #hard_load)
    def self.check_hard_load(mod)
      if not self.is_loaded(mod)
        return self.hard_load(mod)
      end
      return true
    end

    # Get module key by database ID
    # @param [Integer] id module database ID
    # @return [String] module key
    def self.get_key_by_database_id(id)
      ret = BeEF::Core::Configuration.instance.get('beef.module').select {|k, v| v.has_key?('db') and v['db']['id'].to_i == id.to_i }
      return (ret.kind_of?(Array)) ? ret.first.first : ret.keys.first
    end

    # Get module key by module class
    # @param [Class] c module class
    # @return [String] module key
    def self.get_key_by_class(c)
      ret = BeEF::Core::Configuration.instance.get('beef.module').select {|k, v| v.has_key?('class') and v['class'].to_s == c.to_s }
      return (ret.kind_of?(Array)) ? ret.first.first : ret.keys.first
    end

    # Checks to see if module class exists
    # @param [String] mod module key
    # @return [Boolean] returns whether or not the class exists 
    def self.exists?(mod)
      begin
        kclass = BeEF::Core::Command.const_get(mod.capitalize)
        return kclass.is_a?(Class)
      rescue NameError
        return false
      end
    end

    # Checks target configuration to see if browser / version / operating system is supported
    # @param [String] mod module key
    # @param [Hash] opts hash of module support information
    # @return [Constant, nil] returns a resulting defined constant BeEF::Core::Constants::CommandModule::*
    # @note Support uses a rating system to provide the most accurate results.
    #   1 = All match. ie: All was defined.
    #   2 = String match. ie: Firefox was defined as working.
    #   3 = Hash match. ie: Firefox defined with 1 additional parameter (eg max_ver).
    #   4+ = As above but with extra parameters.
    #   Please note this rating system has no correlation to the return constant value BeEF::Core::Constants::CommandModule::*
    def self.support(mod, opts)
      target_config = BeEF::Core::Configuration.instance.get('beef.module.'+mod+'.target')
      if target_config and opts.kind_of? Hash
        if opts.key?('browser')
          results = []
          target_config.each{|k,m|
            m.each{|v|
              case v
                when String
                  if opts['browser'] == v
                    # if k == BeEF::Core::Constants::CommandModule::VERIFIED_NOT_WORKING
                    #   rating += 1
                    # end
                    results << {'rating' => 2, 'const' => k}
                  end
                when Hash
                  if opts['browser'] == v.keys.first or v.keys.first == BeEF::Core::Constants::Browsers::ALL
                    subv = v[v.keys.first]
                    rating = 1
                    #version check
                    if opts.key?('ver')
                      if subv.key?('min_ver')
                        if subv['min_ver'].kind_of? Fixnum and opts['ver'].to_i >= subv['min_ver']
                          rating += 1
                        else
                          break
                        end
                      end
                      if subv.key?('max_ver')
                        if (subv['max_ver'].kind_of? Fixnum and opts['ver'].to_i <= subv['max_ver']) or subv['max_ver'] == "latest"
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
                              match = true
                            end
                          when Array
                            subv['os'].each{|p|
                              if o == p
                                rating += 1
                                match = true
                              elsif p == BeEF::Core::Constants::Os::OS_ALL_UA_STR
                                match = true
                              end
                            }
                        end
                      }
                      if not match
                        break
                      end
                    end
                    if rating > 0
                      # if k == BeEF::Core::Constants::CommandModule::VERIFIED_NOT_WORKING
                      #   rating += 1
                      # end
                      results << {'rating' => rating, 'const' => k}
                    end
                  end
              end
              if v == BeEF::Core::Constants::Browsers::ALL
                rating = 1
                if k == BeEF::Core::Constants::CommandModule::VERIFIED_NOT_WORKING
                  rating = 1
                end
                results << {'rating' => rating, 'const' => k}
              end
            }
          }
          if results.count > 0
            result = {}
            results.each {|r|
              if result == {}
                result = {'rating' => r['rating'], 'const' => r['const']}
              else
                if r['rating'] > result['rating']
                  result = {'rating' => r['rating'], 'const' => r['const']}
                end
              end
            }
            return result['const']
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
    # @note Takes the user defined target configuration and replaces it with equivalent a constant based generated version
    # @param [String] mod module key
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
        BeEF::Core::Configuration.instance.clear("beef.module.#{mod}.target")
        BeEF::Core::Configuration.instance.set("beef.module.#{mod}.target", targets)
      end
    end

    # Translates simple browser target configuration
    # @note Takes a user defined browser type and translates it into a BeEF constant
    # @param [String] v user defined browser
    # @return [Constant] a BeEF browser constant
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
    # @note Takes a complex user defined browser hash and converts it to applicable BeEF constants
    # @param [Hash] v user defined browser hash    
    # @return [Hash] BeEF constants hash
    def self.match_target_browser_spec(v)
      browser = {}
      if v.class == Hash
        if v.key?('max_ver') and (v['max_ver'].is_a?(Fixnum) or v['max_ver'].is_a?(Float) or v['max_ver'] == "latest")
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
    # @note Takes user defined OS specification and translates it into BeEF constants
    # @param [String] v user defined OS string
    # @return [Constant] BeEF OS Constant
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

    # Executes a module 
    # @param [String] mod module key
    # @param [String] hbsession hooked browser session
    # @param [Array] opts array of module execute options (see #get_options)
    # @return [Fixnum] the command_id associated to the module execution when info is persisted. nil if there are errors.
    # @note The return value of this function does not specify if the module was successful, only that it was executed within the framework
    def self.execute(mod, hbsession, opts=[])
      if not (self.is_present(mod) and self.is_enabled(mod))
        print_error "Module not found '#{mod}'. Failed to execute module."
        return nil
      end
      if BeEF::API::Registrar.instance.matched?(BeEF::API::Module, 'override_execute', [mod, nil,nil])
        BeEF::API::Registrar.instance.fire(BeEF::API::Module, 'override_execute', mod, hbsession,opts)
        # @note We return not_nil by default as we cannot determine the correct status if multiple API hooks have been called
        return 'not_available' # @note using metasploit, we cannot know if the module execution was successful or not
      end
      hb = BeEF::HBManager.get_by_session(hbsession)
      if not hb
        print_error "Could not find hooked browser when attempting to execute module '#{mod}'"
        return nil
      end
      self.check_hard_load(mod)
      command_module = self.get_definition(mod).new(mod)
      if command_module.respond_to?(:pre_execute)
        command_module.pre_execute
      end
      h = self.merge_options(mod, [])
      c = BeEF::Core::Models::Command.create(:data => self.merge_options(mod, opts).to_json,
                                          :hooked_browser_id => hb.id,
                                          :command_module_id => BeEF::Core::Configuration.instance.get("beef.module.#{mod}.db.id"),
                                          :creationdate => Time.new.to_i
      )
      return c.id
    end

    # Merges default module options with array of custom options
    # @param [String] mod module key
    # @param [Hash] h module options customised by user input
    # @return [Hash, nil] returns merged options
    def self.merge_options(mod, h)
      if self.is_present(mod)
        self.check_hard_load(mod)
        merged = []
        defaults = self.get_options(mod)
        defaults.each{|v|
          mer = nil
          h.each{|o|
            if v.has_key?('name') and o.has_key?('name') and v['name'] == o['name']
              mer = v.deep_merge(o)
            end
          }
          if mer != nil
            merged.push(mer)
          else
            merged.push(v)
          end
        }
        return merged
      end
      return nil
    end

  end
end


