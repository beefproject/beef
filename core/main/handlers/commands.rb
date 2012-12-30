#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Handlers

      class Commands

        include BeEF::Core::Handlers::Modules::BeEFJS
        include BeEF::Core::Handlers::Modules::Command

        @data = {}

        # Handles command data
        # @param [Hash] data Data from command execution
        # @param [Class] kclass Class of command
        # @todo Confirm argument data variable type [radoen]: type is Hash confirmed.
        def initialize(data, kclass)
          @kclass = BeEF::Core::Command.const_get(kclass.capitalize)
          @data = data
          setup()
        end

        # Initial setup function, creates the command module and saves details to datastore
        def setup()


          @http_params = @data['request'].params
          @http_header = Hash.new
          http_header = @data['request'].env.select { |k, v| k.to_s.start_with? 'HTTP_' }.each { |key, value|
            @http_header[key.sub(/^HTTP_/, '')] = value
          }

          # @note get and check command id from the request
          command_id = get_param(@data, 'cid')
          # @todo ruby filter needs to be updated to detect fixnums not strings
          command_id = command_id.to_s()
          (print_error "command_id is invalid"; return) if not BeEF::Filters.is_valid_command_id?(command_id.to_s())

          # @note get and check session id from the request
          beefhook = get_param(@data, 'beefhook')
          (print_error "BeEFhook is invalid"; return) if not BeEF::Filters.is_valid_hook_session_id?(beefhook)

          result = get_param(@data, 'results')

          # @note create the command module to handle the response
          command = @kclass.new(BeEF::Module.get_key_by_class(@kclass))
          command.build_callback_datastore(@http_params, @http_header, result, command_id, beefhook)
          command.session_id = beefhook
          if command.respond_to?(:post_execute)
            command.post_execute
          end
          #@todo this is the part that store result on db and the modify will be accessible from all the framework and so UI too
          # @note get/set details for datastore and log entry
          command_friendly_name = command.friendlyname
          (print_error "command friendly name is empty"; return) if command_friendly_name.empty?
          command_results = get_param(@data, 'results')
          (print_error "command results are empty"; return) if command_results.empty?
          # @note save the command module results to the datastore and create a log entry
          command_results = {'data' => command_results}
          BeEF::Core::Models::Command.save_result(beefhook, command_id, command_friendly_name, command_results)

        end

        # Returns parameter from hash
        # @param [Hash] query Hash of data to return data from
        # @param [String] key Key to search for and return inside `query`
        # @return Value referenced in hash at the supplied key
        def get_param(query, key)
          return (query.class == Hash and query.has_key?(key)) ? query[key] : nil
        end

      end


    end
  end
end
