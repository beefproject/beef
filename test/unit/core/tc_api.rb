require 'test/unit'
require 'webrick'

class TC_Api < Test::Unit::TestCase

  def setup
    $root_dir="../../"
    $:.unshift File.join( %w{ ../../ } )
  end

  #
  # Test the api is functional
  #
  def test_api
    assert_nothing_raised do
      require 'core/api'
    end
  end

end
