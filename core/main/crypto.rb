module BeEF
module Core
  #
  # This module provides crypto functionality
  #
  module Crypto
    
    # the minimum length of the security token
    TOKEN_MINIMUM_LENGTH = 15
    
    #
    # Generate a secure random token
    #
    # @param: {Integer} the length of the secure token
    #
    def self.secure_token(len = nil)
      # get default length from config
      config = BeEF::Core::Configuration.instance
      token_length = len || config.get('beef.crypto_default_value_length').to_i
      
      # type checking
      raise Exception::TypeError, "Token length is less than the minimum length enforced by the framework: #{TOKEN_MINIMUM_LENGTH}" if (token_length < TOKEN_MINIMUM_LENGTH)
      
      # return random hex string
      return OpenSSL::Random.random_bytes(token_length).unpack("H*")[0]
    end
  
  end
end
end
