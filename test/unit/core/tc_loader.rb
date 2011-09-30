require 'test/unit'
require 'webrick'

class TC_Loader < Test::Unit::TestCase

  def setup
    $root_dir="../../"
    $:.unshift File.join( %w{ ../../ } )
  end

  #
  # Test the loader is functional
  #
  def test_loader
    assert_nothing_raised do
      require 'core/loader'
    end
  end

end
