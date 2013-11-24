#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Evasion
  extend BeEF::API::Extension

  @short_name = 'evasion'
  @full_name = 'Evasion'
  @description = 'Contains Evasion and Obfuscation techniques to prevent the likelihood that BeEF will be detected'
end
end
end

require 'extensions/evasion/evasion'
require 'extensions/evasion/helper'
require 'extensions/evasion/obfuscation/scramble'
require 'extensions/evasion/obfuscation/minify'
require 'extensions/evasion/obfuscation/base_64'
require 'extensions/evasion/obfuscation/whitespace'
