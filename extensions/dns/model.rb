#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      module Dns

        # Represents an individual DNS rule.
        class Rule
          include DataMapper::Resource

          storage_names[:default] = 'extension_dns_rules'

          property :id, String, :key => true
          property :pattern, Object, :required => true
          property :resource, Object, :required => true
          property :response, Object, :required => true
          property :callback, String, :required => true

          # Hooks the model's "save" event. Generates a rule identifier and callback.
          before :save do |rule|
            rule.callback = validate_response(rule.resource, rule.response)
            rule.id = BeEF::Core::Crypto.dns_rule_id
          end

        private
          # Strict validator which ensures that only an appropriate response is given.
          #
          # @param resource [Resolv::DNS::Resource::IN] resource record type
          # @param response [String, Symbol, Array] response to include in callback
          #
          # @return [String] string representation of callback that can safely be eval'd
          def validate_response(resource, response)
            "t.respond!('1.1.1.1')"
          end

        end

      end
    end
  end
end
