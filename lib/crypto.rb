module BeEF

#
# This module provides crypto functionality
#
module Crypto

  #
  # Generate a secure random token
  #
  def self.secure_token(len = nil)
    
    # get default length from config
    config = BeEF::Configuration.instance
    token_length = len || config.get('crypto_default_value_length').to_i

    raise WEBrick::HTTPStatus::BadRequest, "Token length is zero or less" if (1 > token_length)

    # return random hex string
    OpenSSL::Random.random_bytes(token_length).unpack("H*")[0]
    
  end
  
end

end
