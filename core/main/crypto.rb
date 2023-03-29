#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'securerandom'

module BeEF
  module Core
    module Crypto
      # @note the minimum length of the security token
      TOKEN_MINIMUM_LENGTH = 15

      #
      # Generate a secure random token
      #
      # @param [Integer] len The length of the secure token
      #
      # @return [String] Security token
      #
      def self.secure_token(len = nil)
        # get default length from config
        config = BeEF::Core::Configuration.instance
        token_length = len || config.get('beef.crypto_default_value_length').to_i

        # type checking
        raise TypeError, "Token length is less than the minimum length enforced by the framework: #{TOKEN_MINIMUM_LENGTH}" if token_length < TOKEN_MINIMUM_LENGTH

        # return random hex string
        SecureRandom.random_bytes(token_length).unpack1('H*')
      end

      #
      # Generate a secure random token, 20 chars, used as an auth token for the RESTful API.
      # After creation it's stored in the BeEF configuration object => conf.get('beef.api_token')
      #
      # @return [String] Security token
      #
      def self.api_token
        config = BeEF::Core::Configuration.instance
        token_length = 20

        # return random hex string
        token = SecureRandom.random_bytes(token_length).unpack1('H*')
        config.set('beef.api_token', token)
        token
      end

      #
      # Generates a random alphanumeric string
      # Note: this isn't securely random
      # @todo use SecureRandom once Ruby 2.4 is EOL
      #
      # @param length integer length of returned string
      #
      def self.random_alphanum_string(length = 10)
        raise TypeError, "'length' is #{length.class}; expected Integer" unless length.is_a?(Integer)
        raise TypeError, "Invalid length: #{length}" unless length.positive?

        [*('a'..'z'), *('A'..'Z'), *('0'..'9')].shuffle[0, length].join
      end

      #
      # Generates a random hex string
      #
      # @param length integer length of returned string
      #
      def self.random_hex_string(length = 10)
        raise TypeError, "'length' is #{length.class}; expected Integer" unless length.is_a?(Integer)
        raise TypeError, "Invalid length: #{length}" unless length.positive?

        SecureRandom.random_bytes(length).unpack1('H*')[0...length]
      end

      #
      # Generates a unique identifier for DNS rules.
      #
      # @return [String] 8-character hex identifier
      #
      def self.dns_rule_id
        id = nil

        begin
          id = random_hex_string(8)
          BeEF::Core::Models::Dns::Rule.all.each { |rule| throw StandardError if id == rule.id }
        rescue StandardError
          retry
        end

        id.to_s
      end
    end
  end
end
