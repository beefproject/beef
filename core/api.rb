#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module API
    #
    # Registrar class to handle all registered timed API calls
    #
    class Registrar
      include Singleton

      #
      # Create registrar
      #
      def initialize
        @registry = []
        @count = 1
      end

      # Register timed API calls to an owner
      #
      # @param [Class] owner the owner of the API hook
      # @param [Class] clss the API class the owner would like to hook into
      # @param [String] method the method of the class the owner would like to execute
      # @param [Array] params an array of parameters that need to be matched before the owner will be called
      #
      def register(owner, clss, method, params = [])
        unless verify_api_path(clss, method)
          print_error "API Registrar: Attempted to register non-existant API method #{clss} :#{method}"
          return
        end

        if registered?(owner, clss, method, params)
          print_debug "API Registrar: Attempting to re-register API call #{clss} :#{method}"
          return
        end

        id = @count
        @registry << {
          'id' => id,
          'owner' => owner,
          'class' => clss,
          'method' => method,
          'params' => params
        }
        @count += 1

        id
      end

      #
      # Tests whether the owner is registered for an API hook
      #
      # @param [Class] owner the owner of the API hook
      # @param [Class] clss the API class
      # @param [String] method the method of the class
      # @param [Array] params an array of parameters that need to be matched
      #
      # @return [Boolean] whether or not the owner is registered
      #
      def registered?(owner, clss, method, params = [])
        @registry.each do |r|
          next unless r['owner'] == owner
          next unless r['class'] == clss
          next unless r['method'] == method
          next unless is_matched_params? r, params

          return true
        end
        false
      end

      #
      # Match a timed API call to determine if an API.fire() is required
      #
      # @param [Class] clss the target API class
      # @param [String] method the method of the target API class
      # @param [Array] params an array of parameters that need to be matched
      #
      # @return [Boolean] whether or not the arguments match an entry in the API registry
      #
      def matched?(clss, method, params = [])
        @registry.each do |r|
          next unless r['class'] == clss
          next unless r['method'] == method
          next unless is_matched_params? r, params

          return true
        end
        false
      end

      #
      # Un-registers an API hook
      #
      # @param [Integer] id the ID of the API hook
      #
      def unregister(id)
        @registry.delete_if { |r| r['id'] == id }
      end

      #
      # Retrieves all the owners and ID's of an API hook
      # @param [Class] clss the target API class
      # @param [String] method the method of the target API class
      # @param [Array] params an array of parameters that need to be matched
      #
      # @return [Array] an array of hashes consisting of two keys :owner and :id
      #
      def get_owners(clss, method, params = [])
        owners = []
        @registry.each do |r|
          next unless r['class'] == clss
          next unless r['method'] == method
          next unless is_matched_params? r, params

          owners << { owner: r['owner'], id: r['id'] }
        end
        owners
      end

      #
      # Verifies that the api_path has been regitered
      # Verifies the API path has been registered.
      #
      # @note This is a security precaution
      #
      # @param [Class] clss the target API class to verify
      # @param [String] mthd the target method to verify
      #
      def verify_api_path(clss, mthd)
        (clss.const_defined?('API_PATHS') && clss.const_get('API_PATHS').key?(mthd))
      end

      #
      # Retrieves the registered symbol reference for an API hook
      #
      # @param [Class] clss the target API class to verify
      # @param [String] mthd the target method to verify
      #
      # @return [Symbol] the API path
      #
      def get_api_path(clss, mthd)
        verify_api_path(clss, mthd) ? clss.const_get('API_PATHS')[mthd] : nil
      end

      #
      # Matches stored API params to params
      #
      # @note If a stored API parameter has a NilClass the parameter matching is skipped for that parameter
      # @note By default this method returns true, this is either because the API.fire() did not include any parameters or there were no parameters defined for this registry entry
      #
      # @param [Hash] reg hash of registry element, must contain 'params' key
      # @param [Array] params array of parameters to be compared to the stored parameters
      #
      # @return [Boolean] whether params matches the stored API parameters
      #
      def is_matched_params?(reg, params)
        stored = reg['params']
        return true unless stored.length == params.length

        stored.each_index do |i|
          next if stored[i].nil?
          return false unless stored[i] == params[i]
        end

        true
      end

      #
      # Fires all owners registered to this API hook
      #
      # @param [Class] clss the target API class
      # @param [String] mthd the target API method
      # @param [Array] *args parameters passed for the API call
      #
      # @return [Hash, NilClass] returns either a Hash of :api_id and :data
      #         if the owners return data, otherwise NilClass
      #
      def fire(clss, mthd, *args)
        mods = get_owners(clss, mthd, args)
        return nil unless mods.length.positive?

        unless verify_api_path(clss, mthd) && clss.ancestors.first.to_s.start_with?('BeEF::API')
          print_error "API Path not defined for Class: #{clss} method: #{mthd}"
          return []
        end

        data = []
        method = get_api_path(clss, mthd)
        mods.each do |mod|
          # Only used for API Development (very verbose)
          # print_info "API: #{mod} fired #{method}"

          result = mod[:owner].method(method).call(*args)
          data << { api_id: mod[:id], data: result } unless result.nil?
        rescue StandardError => e
          print_error "API Fire Error: #{e.message} in #{mod}.#{method}()"
        end

        data
      end
    end
  end
end

require 'core/api/module'
require 'core/api/modules'
require 'core/api/extension'
require 'core/api/extensions'
require 'core/api/main/migration'
require 'core/api/main/network_stack/assethandler'
require 'core/api/main/server'
require 'core/api/main/server/hook'
require 'core/api/main/configuration'
