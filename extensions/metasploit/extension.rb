module BeEF
module Extension
module Metasploit
  
  extend BeEF::API::Extension
  
  @short_name = @full_name = 'metasploit'
  
  @description = 'use metasploit exploits with beef'
  
end
end
end

require 'extensions/metasploit/filters'
require 'extensions/metasploit/rpcclient'
require 'extensions/metasploit/msfcommand'
require 'extensions/metasploit/dbmigration'
