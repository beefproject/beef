RSpec.describe BeEF::API::Registrar do
  let(:registrar) { described_class.instance }
  let(:test_owner) { Class.new }
  let(:test_api_class) do
    api_class = Class.new
    api_class.const_set(:API_PATHS, { 'test_method' => :test_method }.freeze)
    # Make it appear to be under BeEF::API namespace for fire method
    allow(api_class).to receive(:ancestors).and_return([BeEF::API::Module])
    api_class
  end

  before do
    # Reset singleton state
    registrar.instance_variable_set(:@registry, [])
    registrar.instance_variable_set(:@count, 1)
  end

  describe '#initialize' do
    it 'initializes with empty registry and count of 1' do
      expect(registrar.instance_variable_get(:@registry)).to eq([])
      expect(registrar.instance_variable_get(:@count)).to eq(1)
    end
  end

  describe '#register' do
    it 'registers an API hook' do
      id = registrar.register(test_owner, test_api_class, 'test_method')
      expect(id).to eq(1)
      expect(registrar.instance_variable_get(:@registry).length).to eq(1)
    end

    it 'returns nil when API path does not exist' do
      invalid_class = Class.new
      result = registrar.register(test_owner, invalid_class, 'nonexistent')
      expect(result).to be_nil
      expect(registrar.instance_variable_get(:@registry)).to be_empty
    end

    it 'returns nil when already registered' do
      registrar.register(test_owner, test_api_class, 'test_method')
      result = registrar.register(test_owner, test_api_class, 'test_method')
      expect(result).to be_nil
      expect(registrar.instance_variable_get(:@registry).length).to eq(1)
    end

    it 'increments count for each registration' do
      id1 = registrar.register(test_owner, test_api_class, 'test_method')
      other_owner = Class.new
      id2 = registrar.register(other_owner, test_api_class, 'test_method')
      expect(id1).to eq(1)
      expect(id2).to eq(2)
    end

    it 'accepts params array' do
      id = registrar.register(test_owner, test_api_class, 'test_method', ['param1'])
      expect(id).to eq(1)
      registry = registrar.instance_variable_get(:@registry)
      expect(registry[0]['params']).to eq(['param1'])
    end
  end

  describe '#registered?' do
    it 'returns true when registered' do
      registrar.register(test_owner, test_api_class, 'test_method')
      expect(registrar.registered?(test_owner, test_api_class, 'test_method')).to be true
    end

    it 'returns false when not registered' do
      expect(registrar.registered?(test_owner, test_api_class, 'test_method')).to be false
    end

    it 'matches params when checking registration' do
      registrar.register(test_owner, test_api_class, 'test_method', ['param1'])
      expect(registrar.registered?(test_owner, test_api_class, 'test_method', ['param1'])).to be true
      expect(registrar.registered?(test_owner, test_api_class, 'test_method', ['param2'])).to be false
    end
  end

  describe '#matched?' do
    it 'returns true when a registration matches' do
      registrar.register(test_owner, test_api_class, 'test_method')
      expect(registrar.matched?(test_api_class, 'test_method')).to be true
    end

    it 'returns false when no registration matches' do
      expect(registrar.matched?(test_api_class, 'test_method')).to be false
    end
  end

  describe '#unregister' do
    it 'removes registration by id' do
      id = registrar.register(test_owner, test_api_class, 'test_method')
      registrar.unregister(id)
      expect(registrar.instance_variable_get(:@registry)).to be_empty
    end
  end

  describe '#get_owners' do
    it 'returns owners for a registered API hook' do
      id = registrar.register(test_owner, test_api_class, 'test_method')
      owners = registrar.get_owners(test_api_class, 'test_method')
      expect(owners.length).to eq(1)
      expect(owners[0][:owner]).to eq(test_owner)
      expect(owners[0][:id]).to eq(id)
    end

    it 'returns empty array when no owners registered' do
      owners = registrar.get_owners(test_api_class, 'test_method')
      expect(owners).to eq([])
    end
  end

  describe '#verify_api_path' do
    it 'returns true for valid API path' do
      expect(registrar.verify_api_path(test_api_class, 'test_method')).to be true
    end

    it 'returns false for invalid API path' do
      expect(registrar.verify_api_path(test_api_class, 'nonexistent')).to be false
    end

    it 'returns false for class without API_PATHS constant' do
      invalid_class = Class.new
      # Remove API_PATHS if it exists from previous tests
      invalid_class.send(:remove_const, :API_PATHS) if invalid_class.const_defined?(:API_PATHS)
      expect(registrar.verify_api_path(invalid_class, 'test_method')).to be false
    end
  end

  describe '#get_api_path' do
    it 'returns symbol for valid API path' do
      expect(registrar.get_api_path(test_api_class, 'test_method')).to eq(:test_method)
    end

    it 'returns nil for invalid API path' do
      expect(registrar.get_api_path(test_api_class, 'nonexistent')).to be_nil
    end
  end

  describe '#is_matched_params?' do
    it 'returns true when params match' do
      reg = { 'params' => ['param1', 'param2'] } # rubocop:disable Style/WordArray
      expect(registrar.is_matched_params?(reg, ['param1', 'param2'])).to be true # rubocop:disable Style/WordArray
    end

    it 'returns false when params do not match' do
      reg = { 'params' => ['param1'] }
      expect(registrar.is_matched_params?(reg, ['param2'])).to be false
    end

    it 'returns true when stored params include nil' do
      reg = { 'params' => ['param1', nil] }
      expect(registrar.is_matched_params?(reg, ['param1', 'anything'])).to be true # rubocop:disable Style/WordArray
    end

    it 'returns true when lengths do not match (early return)' do
      reg = { 'params' => ['param1'] }
      expect(registrar.is_matched_params?(reg, ['param1', 'param2'])).to be true # rubocop:disable Style/WordArray
    end

    it 'returns true when stored params is empty' do
      reg = { 'params' => [] }
      expect(registrar.is_matched_params?(reg, [])).to be true
    end
  end

  describe '#fire' do
    let(:mock_owner_class) do
      Class.new do
        def self.test_method(arg)
          "result_#{arg}"
        end
      end
    end

    it 'fires registered API hooks' do
      registrar.register(mock_owner_class, test_api_class, 'test_method')
      result = registrar.fire(test_api_class, 'test_method', 'test_arg')
      expect(result.length).to eq(1)
      expect(result[0][:data]).to eq('result_test_arg')
    end

    it 'returns nil when no owners registered' do
      result = registrar.fire(test_api_class, 'test_method')
      expect(result).to be_nil
    end

    it 'returns empty array when API path not defined but class is registered' do
      # Create a class that passes registration but fails verify_api_path in fire
      invalid_class = Class.new
      invalid_class.const_set(:API_PATHS, { 'test_method' => :test_method }.freeze)
      allow(invalid_class).to receive(:ancestors).and_return([Class.new]) # Not under BeEF::API
      registrar.register(mock_owner_class, invalid_class, 'test_method')
      result = registrar.fire(invalid_class, 'test_method')
      expect(result).to eq([])
    end

    it 'handles errors gracefully' do
      error_owner_class = Class.new do
        def self.test_method
          raise StandardError, 'Test error'
        end
      end
      registrar.register(error_owner_class, test_api_class, 'test_method')
      expect { registrar.fire(test_api_class, 'test_method') }.not_to raise_error
    end

    it 'skips nil results' do
      nil_owner_class = Class.new do
        def self.test_method
          nil
        end
      end
      registrar.register(nil_owner_class, test_api_class, 'test_method')
      result = registrar.fire(test_api_class, 'test_method')
      expect(result).to eq([])
    end
  end
end
