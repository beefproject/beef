#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'
require 'resolv'

class TC_Dns < Test::Unit::TestCase

  class << self

    def startup
      $:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '../../../'))

      require 'core/loader'
      require 'extensions/dns/extension'

      config = BeEF::Core::Configuration.instance

      @@address = config.get('beef.extension.dns.address')
      @@port    = config.get('beef.extension.dns.port')

      Thread.new do
        dns = BeEF::Extension::Dns::Server.instance
        dns.run_server(@@address, @@port)
      end
    end

  end

  def test_add_rule
    dns = BeEF::Extension::Dns::Server.instance

    id = dns.add_rule('foo.bar', Resolv::DNS::Resource::IN::A) do |transaction|
      transaction.respond!('1.2.3.4')
    end

    assert_not_nil(id)
  end

end
