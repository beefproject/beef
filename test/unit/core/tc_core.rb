require 'test/unit'
require 'webrick'

class TC_Core < Test::Unit::TestCase

  def setup
    $root_dir="../../"
    $:.unshift File.join( %w{ ../../ } )
  end

  #
  # Test the core is functional
  #
  def test_core
    assert_nothing_raised do
      require 'core/core'
    end
  end

end
