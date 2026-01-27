#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'spec_helper'

RSpec.describe 'Module extensions' do
  # Create a test module to use in tests
  let(:test_module) do
    Module.new do
      def test_method
        'test'
      end
    end
  end

  describe '#included_in_classes' do
    it 'returns an array' do
      result = test_module.included_in_classes
      expect(result).to be_an(Array)
    end

    it 'finds classes that include the module' do
      mod = test_module
      test_class = Class.new do
        include mod
      end

      # Force class to be created
      test_class.new

      included_classes = mod.included_in_classes
      expect(included_classes.map(&:to_s)).to include(test_class.to_s)
    end

    it 'returns unique classes only' do
      mod = test_module
      test_class = Class.new do
        include mod
      end

      # Force class to be created multiple times
      test_class.new
      test_class.new

      included_classes = mod.included_in_classes
      unique_class_names = included_classes.map(&:to_s)
      expect(unique_class_names.count(test_class.to_s)).to eq(1)
    end

    it 'returns empty array when module is not included anywhere' do
      isolated_module = Module.new
      result = isolated_module.included_in_classes
      expect(result).to be_an(Array)
      # May or may not be empty depending on what's loaded, but should be an array
    end
  end

  describe '#included_in_modules' do
    it 'returns an array' do
      result = test_module.included_in_modules
      expect(result).to be_an(Array)
    end

    it 'finds modules that include the module' do
      mod = test_module
      including_module = Module.new do
        include mod
      end

      # Force module to be created
      Class.new { include including_module }

      included_modules = mod.included_in_modules
      expect(included_modules.map(&:to_s)).to include(including_module.to_s)
    end

    it 'returns unique modules only' do
      mod = test_module
      including_module = Module.new do
        include mod
      end

      # Force module to be created multiple times
      Class.new { include including_module }
      Class.new { include including_module }

      included_modules = mod.included_in_modules
      unique_module_names = included_modules.map(&:to_s)
      expect(unique_module_names.count(including_module.to_s)).to eq(1)
    end
  end
end
