#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Evasion
      # Common methods used by multiple obfuscation techniques
      module Helper

        def self.random_string(length=5)
          chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ'
          result = ''
          length.times { result << chars[rand(chars.size)] }
          result
        end

      end
    end
  end
end

