#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Module
    # Checks to see if module key is in configuration
    # @param [String] mod module key
    # @return [Boolean] if the module key exists in BeEF's configuration
    def self.is_present(mod)
      BeEF::Core::Configuration.instance.get('beef.module').key? mod.to_s
    end

    # Checks to see if module is enabled in configuration
    # @param [String] mod module key
    # @return [Boolean] if the module key is enabled in BeEF's configuration
    def self.is_enabled(mod)
      (is_present(mod) && BeEF::Core::Configuration.instance.get("beef.module.#{mod}.enable") == true)
    end

    # Checks to see if the module reports that it has loaded through the configuration
    # @param [String] mod module key
    # @return [Boolean] if the module key is loaded in BeEF's configuration
    def self.is_loaded(mod)
      (is_enabled(mod) && BeEF::Core::Configuration.instance.get("beef.module.#{mod}.loaded") == true)
    end

    # Returns module class definition
    # @param [String] mod module key
    # @return [Class] the module class
    def self.get_definition(mod)
      BeEF::Core::Command.const_get(BeEF::Core::Configuration.instance.get("beef.module.#{mod}.class"))
    end

    # Gets all module options
    # @param [String] mod module key
    # @return [Hash] a hash of all the module options
    # @note API Fire: get_options
    def self.get_options(mod)
      if BeEF::API::Registrar.instance.matched? BeEF::API::Module, 'get_options', [mod]
        options = BeEF::API::Registrar.instance.fire BeEF::API::Module, 'get_options', mod
        mo = []
        options.each do |o|
          unless o[:data].is_a?(Array)
            print_debug 'API Warning: return result for BeEF::Module.get_options() was not an array.'
            next
          end
          mo += o[:data]
        end
        return mo
      end

      unless check_hard_load mod
        print_debug "get_opts called on unloaded module '#{mod}'"
        return []
      end

      class_name = BeEF::Core::Configuration.instance.get "beef.module.#{mod}.class"
      class_symbol = BeEF::Core::Command.const_get class_name

      return [] unless class_symbol && class_symbol.respond_to?(:options)

      class_symbol.options
    end

    # Gets all module payload options
    # @param [String] mod module key
    # @return [Hash] a hash of all the module options
    # @note API Fire: get_options
    def self.get_payload_options(mod, payload)
      return [] unless BeEF::API::Registrar.instance.matched?(BeEF::API::Module, 'get_payload_options', [mod, nil])

      BeEF::API::Registrar.instance.fire(BeEF::API::Module, 'get_payload_options', mod, payload)
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

      mod_str = "beef.module.#{mod}"
      if config.get("#{mod_str}.loaded")
        print_error "Unable to load module '#{mod}'"
        return false
      end

      mod_path = "#{$root_dir}/#{config.get("#{mod_str}.path")}/module.rb"
      unless File.exist? mod_path
        print_debug "Unable to locate module file: #{mod_path}"
        return false
      end

      BeEF::Core::Configuration.instance.set("#{mod_str}.class", mod.capitalize)
      parse_targets mod
      print_debug "Soft Load module: '#{mod}'"

      # API call for post-soft-load module
      BeEF::API::Registrar.instance.fire(BeEF::API::Module, 'post_soft_load', mod)
      true
    rescue StandardError => e
      print_error "There was a problem soft loading the module '#{mod}': #{e.message}"
      false
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

      unless is_enabled mod
        print_error "Hard load attempted on module '#{mod}' that is not enabled."
        return false
      end

      mod_str = "beef.module.#{mod}"
      mod_path = "#{config.get("#{mod_str}.path")}/module.rb"
      require mod_path

      unless exists? config.get("#{mod_str}.class")
        print_error "Hard loaded module '#{mod}' but the class BeEF::Core::Commands::#{mod.capitalize} does not exist"
        return false
      end

      # start server mount point
      BeEF::Core::Server.instance.mount("/command/#{mod}.js", BeEF::Core::Handlers::Commands, mod)
      BeEF::Core::Configuration.instance.set("#{mod_str}.mount", "/command/#{mod}.js")
      BeEF::Core::Configuration.instance.set("#{mod_str}.loaded", true)
      print_debug "Hard Load module: '#{mod}'"

      # API call for post-hard-load module
      BeEF::API::Registrar.instance.fire(BeEF::API::Module, 'post_hard_load', mod)
      true
    rescue StandardError => e
      BeEF::Core::Configuration.instance.set("#{mod_str}.loaded", false)
      print_error "There was a problem loading the module '#{mod}'"
      print_debug "Hard load module syntax error: #{e}"
      false
    end

    # Checks to see if a module has been hard loaded, if not a hard load is attempted
    # @param [String] mod module key
    # @return [Boolean] if already hard loaded then true otherwise (see #hard_load)
    def self.check_hard_load(mod)
      return true if is_loaded mod

      hard_load mod
    end

    # Get module key by database ID
    # @param [Integer] id module database ID
    # @return [String] module key
    def self.get_key_by_database_id(id)
      ret = BeEF::Core::Configuration.instance.get('beef.module').select do |_k, v|
        v.key?('db') && v['db']['id'].to_i == id.to_i
      end
      ret.is_a?(Array) ? ret.first.first : ret.keys.first
    end

    # Get module key by module class
    # @param [Class] c module class
    # @return [String] module key
    def self.get_key_by_class(c)
      ret = BeEF::Core::Configuration.instance.get('beef.module').select do |_k, v|
        v.key?('class') && v['class'].to_s.eql?(c.to_s)
      end
      ret.is_a?(Array) ? ret.first.first : ret.keys.first
    end

    # Checks to see if module class exists
    # @param [String] mod module key
    # @return [Boolean] returns whether or not the class exists
    def self.exists?(mod)
      kclass = BeEF::Core::Command.const_get mod.capitalize
      kclass.is_a? Class
    rescue NameError
      false
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
      target_config = BeEF::Core::Configuration.instance.get("beef.module.#{mod}.target")
      return nil unless target_config
      return nil unless opts.is_a? Hash

      unless opts.key? 'browser'
        print_error 'BeEF::Module.support() was passed a hash without a valid browser constant'
        return nil
      end

      results = []
      target_config.each do |k, m|
        m.each do |v|
          case v
          when String
            if opts['browser'] == v
              # if k == BeEF::Core::Constants::CommandModule::VERIFIED_NOT_WORKING
              #   rating += 1
              # end
              results << { 'rating' => 2, 'const' => k }
            end
          when Hash
            break if opts['browser'] != v.keys.first && v.keys.first != BeEF::Core::Constants::Browsers::ALL

            subv = v[v.keys.first]
            rating = 1

            # version check
            if opts.key?('ver')
              if subv.key?('min_ver')
                break unless subv['min_ver'].is_a?(Integer) && opts['ver'].to_i >= subv['min_ver']
                rating += 1
              end
              if subv.key?('max_ver')
                break unless (subv['max_ver'].is_a?(Integer) && opts['ver'].to_i <= subv['max_ver']) || subv['max_ver'] == 'latest'
                rating += 1
              end
            end

            # os check
            if opts.key?('os') && subv.key?('os')
              match = false
              opts['os'].each do |o|
                case subv['os']
                when String
                  if o == subv['os']
                    rating += 1
                    match = true
                  elsif subv['os'].eql? BeEF::Core::Constants::Os::OS_ALL_UA_STR
                    match = true
                  end
                when Array
                  subv['os'].each do |p|
                    if o == p
                      rating += 1
                      match = true
                    elsif p.eql? BeEF::Core::Constants::Os::OS_ALL_UA_STR
                      match = true
                    end
                  end
                end
              end
              break unless match
            end

            if rating.positive?
              # if k == BeEF::Core::Constants::CommandModule::VERIFIED_NOT_WORKING
              #   rating += 1
              # end
              results << { 'rating' => rating, 'const' => k }
            end
          end

          next unless v.eql? BeEF::Core::Constants::Browsers::ALL

          rating = 1
          rating = 1 if k == BeEF::Core::Constants::CommandModule::VERIFIED_NOT_WORKING

          results << { 'rating' => rating, 'const' => k }
        end
      end

      return BeEF::Core::Constants::CommandModule::VERIFIED_UNKNOWN unless results.count.positive?

      result = {}
      results.each do |r|
        result = { 'rating' => r['rating'], 'const' => r['const'] } if result == {} || r['rating'] > result['rating']
      end

      result['const']
    end

    # Translates module target configuration
    # @note Takes the user defined target configuration and replaces it with equivalent a constant based generated version
    # @param [String] mod module key
    def self.parse_targets(mod)
      mod_str = "beef.module.#{mod}"
      target_config = BeEF::Core::Configuration.instance.get("#{mod_str}.target")
      return unless target_config

      targets = {}
      target_config.each do |k, v|
        next unless BeEF::Core::Constants::CommandModule.const_defined? "VERIFIED_#{k.upcase}"

        key = BeEF::Core::Constants::CommandModule.const_get "VERIFIED_#{k.upcase}"
        targets[key] = [] unless targets.key? key
        browser = nil

        case v
        when String
          browser = match_target_browser v
          targets[key] << browser if browser
        when Array
          v.each do |c|
            browser = match_target_browser c
            targets[key] << browser if browser
          end
        when Hash
          v.each do |k, c|
            browser = match_target_browser k
            next unless browser

            case c
            when TrueClass
              targets[key] << browser
            when Hash
              details = match_target_browser_spec c
              targets[key] << { browser => details } if details
            end
          end
        end
      rescue NameError
        print_error "Module '#{mod}' configuration has invalid target status defined '#{k}'"
      end

      BeEF::Core::Configuration.instance.clear "#{mod_str}.target"
      BeEF::Core::Configuration.instance.set "#{mod_str}.target", targets
    end

    # Translates simple browser target configuration
    # @note Takes a user defined browser type and translates it into a BeEF constant
    # @param [String] v user defined browser
    # @return [Constant] a BeEF browser constant
    def self.match_target_browser(v)
      unless v.instance_of?(String)
        print_error 'Invalid datatype passed to BeEF::Module.match_target_browser()'
        return false
      end

      return false unless BeEF::Core::Constants::Browsers.const_defined? v.upcase

      BeEF::Core::Constants::Browsers.const_get v.upcase
    rescue NameError
      print_error "Could not identify browser target specified as '#{v}'"
      false
    end

    # Translates complex browser target configuration
    # @note Takes a complex user defined browser hash and converts it to applicable BeEF constants
    # @param [Hash] v user defined browser hash
    # @return [Hash] BeEF constants hash
    def self.match_target_browser_spec(v)
      unless v.instance_of?(Hash)
        print_error 'Invalid datatype passed to BeEF::Module.match_target_browser_spec()'
        return {}
      end

      browser = {}
      browser['max_ver'] = v['max_ver'] if v.key?('max_ver') && (v['max_ver'].is_a?(Integer) || v['max_ver'].is_a?(Float) || v['max_ver'] == 'latest')

      browser['min_ver'] = v['min_ver'] if v.key?('min_ver') && (v['min_ver'].is_a?(Integer) || v['min_ver'].is_a?(Float))

      return browser unless v.key?('os')

      case v['os']
      when String
        os = match_target_os v['os']
        browser['os'] = os if os
      when Array
        browser['os'] = []
        v['os'].each do |c|
          os = match_target_os c
          browser['os'] << os if os
        end
      end

      browser
    end

    # Translates simple OS target configuration
    # @note Takes user defined OS specification and translates it into BeEF constants
    # @param [String] v user defined OS string
    # @return [Constant] BeEF OS Constant
    def self.match_target_os(v)
      unless v.instance_of?(String)
        print_error 'Invalid datatype passed to BeEF::Module.match_target_os()'
        return false
      end

      return false unless BeEF::Core::Constants::Os.const_defined? "OS_#{v.upcase}_UA_STR"

      BeEF::Core::Constants::Os.const_get "OS_#{v.upcase}_UA_STR"
    rescue NameError
      print_error "Could not identify OS target specified as '#{v}'"
      false
    end

    # Executes a module
    # @param [String] mod module key
    # @param [String] hbsession hooked browser session
    # @param [Array] opts array of module execute options (see #get_options)
    # @return [Integer] the command_id associated to the module execution when info is persisted. nil if there are errors.
    # @note The return value of this function does not specify if the module was successful, only that it was executed within the framework
    def self.execute(mod, hbsession, opts = [])
      unless is_present(mod) && is_enabled(mod)
        print_error "Module not found '#{mod}'. Failed to execute module."
        return nil
      end

      if BeEF::API::Registrar.instance.matched? BeEF::API::Module, 'override_execute', [mod, nil, nil]
        BeEF::API::Registrar.instance.fire BeEF::API::Module, 'override_execute', mod, hbsession, opts
        # @note We return not_nil by default as we cannot determine the correct status if multiple API hooks have been called
        # @note using metasploit, we cannot know if the module execution was successful or not
        return 'not_available'
      end

      hb = BeEF::HBManager.get_by_session hbsession
      unless hb
        print_error "Could not find hooked browser when attempting to execute module '#{mod}'"
        return nil
      end

      check_hard_load mod
      command_module = get_definition(mod).new(mod)
      command_module.pre_execute if command_module.respond_to?(:pre_execute)
      merge_options(mod, [])
      c = BeEF::Core::Models::Command.create(
        data: merge_options(mod, opts).to_json,
        hooked_browser_id: hb.id,
        command_module_id: BeEF::Core::Configuration.instance.get("beef.module.#{mod}.db.id"),
        creationdate: Time.new.to_i
      )
      c.id
    end

    # Merges default module options with array of custom options
    # @param [String] mod module key
    # @param [Hash] opts module options customised by user input
    # @return [Hash, nil] returns merged options
    def self.merge_options(mod, opts)
      return nil unless is_present mod

      check_hard_load mod
      merged = []
      defaults = get_options mod
      defaults.each do |v|
        mer = nil
        opts.each do |o|
          mer = v.deep_merge o if v.key?('name') && o.key?('name') && v['name'] == o['name']
        end

        mer.nil? ? merged.push(v) : merged.push(mer)
      end

      merged
    end
  end
end
