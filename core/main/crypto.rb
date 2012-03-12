#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
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
module Core

  module Crypto
    
    # @note the minimum length of the security token
    TOKEN_MINIMUM_LENGTH = 15
    
    # Generate a secure random token
    # @param [Integer] len The length of the secure token
    # @return [String] Security token
    def self.secure_token(len = nil)
      # get default length from config
      config = BeEF::Core::Configuration.instance
      token_length = len || config.get('beef.crypto_default_value_length').to_i
      
      # type checking
      raise Exception::TypeError, "Token length is less than the minimum length enforced by the framework: #{TOKEN_MINIMUM_LENGTH}" if (token_length < TOKEN_MINIMUM_LENGTH)
      
      # return random hex string
      return OpenSSL::Random.random_bytes(token_length).unpack("H*")[0]
    end

    # Generate a secure random token, 20 chars, used as an auth token for the RESTful API.
    # After creation it's stored in the BeEF configuration object => conf.get('beef.api_token')
    # @return [String] Security token
    def self.api_token
      config = BeEF::Core::Configuration.instance
      token_length = 20

      # return random hex string
      token = OpenSSL::Random.random_bytes(token_length).unpack("H*")[0]
      config.set('beef.api_token', token)
      token
    end
  
  end
end
end
