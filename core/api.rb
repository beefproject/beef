#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module API

    # Registrar class to handle all registered timed API calls
    class Registrar

      include Singleton

      # Create registrar
      def initialize
        @registry = []
        @count = 1
      end

      # Register timed API calls to an owner
      # @param [Class] owner the owner of the API hook
      # @param [Class] c the API class the owner would like to hook into
      # @param [String] method the method of the class the owner would like to execute
      # @param [Array] params an array of parameters that need to be matched before the owner will be called
      def register(owner, c, method, params = [])
        if self.verify_api_path(c, method)
          if not self.registered?(owner, c, method, params)
            id = @count
            @registry << {
                'id' => id,
                'owner' => owner,
                'class' => c,
                'method' => method,
                'params' => params
            }
            @count += 1
            return id
          else
            print_debug "API Registrar: Attempting to re-register API call #{c.to_s} :#{method.to_s}"
          end
        else
          print_error "API Registrar: Attempted to register non-existant API method #{c.to_s} :#{method.to_s}"
        end
      end

      # Tests whether the owner is registered for an API hook
      # @param [Class] owner the owner of the API hook
      # @param [Class] c the API class
      # @param [String] method the method of the class
      # @param [Array] params an array of parameters that need to be matched
      # @return [Boolean] whether or not the owner is registered
      def registered?(owner, c, method, params = [])
        @registry.each{|r|
          if r['owner'] == owner and r['class'] == c and r['method'] == method and self.is_matched_params?(r, params)
            return true
          end
        }
        return false
      end

      # Match a timed API call to determine if an API.fire() is required
      # @param [Class] c the target API class
      # @param [String] method the method of the target API class
      # @param [Array] params an array of parameters that need to be matched
      # @return [Boolean] whether or not the arguments match an entry in the API registry
      def matched?(c, method, params = [])
        @registry.each{|r|
          if r['class'] == c and r['method'] == method and self.is_matched_params?(r, params)
            return true
          end
        }
        return false
      end

      # Un-registers an API hook
      # @param [Integer] id the ID of the API hook
      def unregister(id)
        @registry.delete_if{|r|
          r['id'] == id
        }
      end

      # Retrieves all the owners and ID's of an API hook
      # @param [Class] c the target API class
      # @param [String] method the method of the target API class
      # @param [Array] params an array of parameters that need to be matched
      # @return [Array] an array of hashes consisting of two keys :owner and :id
      def get_owners(c, method, params = [])
        owners = []
        @registry.each{|r|
          if r['class'] == c and r['method'] == method
            if self.is_matched_params?(r, params)
              owners << { :owner => r['owner'], :id => r['id']}
            end
          end
        }
        return owners
      end

      # Verifies that the api_path has been regitered
      # Verifies the API path has been registered.
      # @note This is a security precaution
      # @param [Class] c the target API class to verify
      # @param [String] m the target method to verify
      def verify_api_path(c, m)
        return (c.const_defined?('API_PATHS') and c.const_get('API_PATHS').has_key?(m))
      end

      # Retrieves the registered symbol reference for an API hook
      # @param [Class] c the target API class to verify
      # @param [String] m the target method to verify
      # @return [Symbol] the API path
      def get_api_path(c, m)
        return (self.verify_api_path(c, m)) ? c.const_get('API_PATHS')[m] : nil;
      end

      # Matches stored API params to params
      # @note If a stored API parameter has a NilClass the parameter matching is skipped for that parameter
      # @note By default this method returns true, this is either because the API.fire() did not include any parameters or there were no parameters defined for this registry entry
      # @param [Hash] reg hash of registry element, must contain 'params' key
      # @param [Array] params array of parameters to be compared to the stored parameters
      # @return [Boolean] whether params matches the stored API parameters
      def is_matched_params?(reg, params)
        stored = reg['params']
        if stored.length == params.length
          matched = true
          stored.each_index{|i|
            next if stored[i] == nil
            if not stored[i] == params[i]
              matched = false
            end
          }
          return false if not matched
        end
        return true
      end

      # Fires all owners registered to this API hook
      # @param [Class] c the target API class
      # @param [String] m the target API method
      # @param [Array] *args parameters passed for the API call
      # @return [Hash, NilClass] returns either a Hash of :api_id and :data if the owners return data, otherwise NilClass
      def fire(c, m, *args)
        mods = self.get_owners(c, m, args)
        if mods.length > 0
          data = []
          if self.verify_api_path(c, m) and c.ancestors[0].to_s > "BeEF::API"
            method = self.get_api_path(c, m)
            mods.each do |mod|
              begin
                #Only used for API Development (very verbose)
                #print_info "API: #{mod} fired #{method}"
                result = mod[:owner].method(method).call(*args)
                if not result == nil
                  data << {:api_id => mod[:id], :data => result}
                end
              rescue Exception => e
                print_error "API Fire Error: #{e.message} in #{mod.to_s}.#{method.to_s}()"
              end
            end
          else
            print_error "API Path not defined for Class: #{c.to_s} method:#{method.to_s}"
          end
          return data
        end
        return nil
      end

    end

  end
end

require 'core/api/module'
require 'core/api/modules'
require 'core/api/extension'
require 'core/api/extensions'
require 'core/api/main/migration'
require 'core/api/main/network_stack/assethandler.rb'
require 'core/api/main/server'
require 'core/api/main/server/hook'
require 'core/api/main/configuration'

