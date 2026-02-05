#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Core::Command do
  let(:config) { BeEF::Core::Configuration.instance }

  before do
    # Ensure modules are loaded
    BeEF::Modules.load if config.get('beef.module').nil?

    # Set up a test module configuration if it doesn't exist
    unless config.get('beef.module.test_get_variable')
      config.set('beef.module.test_get_variable.name', 'Test Get Variable')
      config.set('beef.module.test_get_variable.path', 'modules/test/')
      config.set('beef.module.test_get_variable.mount', '/command/test_get_variable.js')
      config.set('beef.module.test_get_variable.db.id', 1)
    end
  end

  describe BeEF::Core::CommandUtils do
    describe '#format_multiline' do
      it 'converts newlines to escaped newlines' do
        result = BeEF::Core::CommandUtils.instance_method(:format_multiline).bind(Object.new).call("line1\nline2")
        expect(result).to eq("line1\\nline2")
      end

      it 'handles strings without newlines' do
        result = BeEF::Core::CommandUtils.instance_method(:format_multiline).bind(Object.new).call("single line")
        expect(result).to eq("single line")
      end
    end
  end

  describe BeEF::Core::CommandContext do
    it 'initializes with hash' do
      context = described_class.new({ 'key' => 'value' })
      expect(context['key']).to eq('value')
    end

    it 'initializes without hash' do
      context = described_class.new
      expect(context).to be_a(Erubis::Context)
    end

    it 'includes CommandUtils' do
      context = described_class.new
      expect(context).to respond_to(:format_multiline)
    end
  end

  describe '#initialize' do
    it 'initializes with module key' do
      command = described_class.new('test_get_variable')
      expect(command.config).to eq(config)
      expect(command.datastore).to eq({})
      expect(command.beefjs_components).to eq({})
    end

    it 'sets friendlyname from configuration' do
      # Mock all config calls for initialization
      allow(config).to receive(:get).and_call_original
      allow(config).to receive(:get).with('beef.module.test_get_variable.name').and_return('Test Get Variable')
      allow(config).to receive(:get).with('beef.module.test_get_variable.path').and_return('modules/test/')
      allow(config).to receive(:get).with('beef.module.test_get_variable.mount').and_return('/command/test.js')
      allow(config).to receive(:get).with('beef.module.test_get_variable.db.id').and_return(1)
      command = described_class.new('test_get_variable')
      expect(command.friendlyname).to eq('Test Get Variable')
    end
  end

  describe '#needs_configuration?' do
    it 'returns true when datastore is not nil' do
      command = described_class.new('test_get_variable')
      command.instance_variable_set(:@datastore, {})
      expect(command.needs_configuration?).to be true
    end

    it 'returns false when datastore is nil' do
      command = described_class.new('test_get_variable')
      command.instance_variable_set(:@datastore, nil)
      expect(command.needs_configuration?).to be false
    end
  end

  describe '#to_json' do
    it 'returns JSON with command information' do
      # Mock all config calls for this test
      allow(config).to receive(:get).and_call_original
      allow(config).to receive(:get).with('beef.module.test_get_variable.name').and_return('Test Get Variable')
      allow(config).to receive(:get).with('beef.module.test_get_variable.description').and_return('Test Description')
      allow(config).to receive(:get).with('beef.module.test_get_variable.category').and_return('Test Category')
      allow(config).to receive(:get).with('beef.module.test_get_variable.path').and_return('modules/test/')
      allow(config).to receive(:get).with('beef.module.test_get_variable.mount').and_return('/command/test.js')
      allow(config).to receive(:get).with('beef.module.test_get_variable.db.id').and_return(1)
      allow(BeEF::Module).to receive(:get_options).with('test_get_variable').and_return([])
      command = described_class.new('test_get_variable')
      json = command.to_json
      parsed = JSON.parse(json)
      expect(parsed['Name']).to eq('Test Get Variable')
      expect(parsed['Description']).to eq('Test Description')
      expect(parsed['Category']).to eq('Test Category')
    end
  end

  describe '#build_datastore' do
    it 'parses JSON data into datastore' do
      command = described_class.new('test_get_variable')
      data = '{"key": "value"}'
      command.build_datastore(data)
      expect(command.datastore).to eq({ 'key' => 'value' })
    end

    it 'handles invalid JSON gracefully' do
      command = described_class.new('test_get_variable')
      command.build_datastore('invalid json')
      expect(command.datastore).to eq({})
    end
  end

  describe '#build_callback_datastore' do
    it 'initializes datastore with http_headers' do
      command = described_class.new('test_get_variable')
      command.build_callback_datastore('result', 1, 'hook', nil, nil)
      expect(command.datastore).to have_key('http_headers')
      expect(command.datastore['http_headers']).to eq({})
    end

    it 'adds results, command_id, and beefhook' do
      command = described_class.new('test_get_variable')
      command.build_callback_datastore('result', 1, 'hook', nil, nil)
      expect(command.datastore['results']).to eq('result')
      expect(command.datastore['cid']).to eq(1)
      expect(command.datastore['beefhook']).to eq('hook')
    end

    it 'adds valid http_params to datastore' do
      allow(BeEF::Filters).to receive(:is_valid_command_module_datastore_key?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_command_module_datastore_param?).and_return(true)
      allow(Erubis::XmlHelper).to receive(:escape_xml) { |arg| arg }
      command = described_class.new('test_get_variable')
      command.build_callback_datastore('result', 1, 'hook', { 'param1' => 'value1' }, {})
      expect(command.datastore['param1']).to eq('value1')
    end

    it 'skips invalid http_params' do
      allow(BeEF::Filters).to receive(:is_valid_command_module_datastore_key?).and_return(false)
      command = described_class.new('test_get_variable')
      command.build_callback_datastore('result', 1, 'hook', { 'invalid' => 'value' }, {})
      expect(command.datastore).not_to have_key('invalid')
    end
  end

  describe '#save' do
    it 'saves results' do
      command = described_class.new('test_get_variable')
      results = { 'data' => 'test' }
      command.save(results)
      expect(command.instance_variable_get(:@results)).to eq(results)
    end
  end

  describe '#map_file_to_url' do
    it 'calls AssetHandler bind' do
      mock_handler = double('AssetHandler')
      allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(mock_handler)
      expect(mock_handler).to receive(:bind).with('file.txt', nil, nil, 1)
      command = described_class.new('test_get_variable')
      command.map_file_to_url('file.txt')
    end
  end

  describe '#use' do
    it 'adds component to beefjs_components when file exists' do
      # The path construction adds an extra /, so account for that
      component_path = "#{$root_dir}/core/main/client//net/local.js"
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(component_path).and_return(true)
      command = described_class.new('test_get_variable')
      command.use('beef.net.local')
      expect(command.beefjs_components).to have_key('beef.net.local')
    end

    it 'raises error when component file does not exist' do
      component_path = "#{$root_dir}/core/main/client//net/nonexistent.js"
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(component_path).and_return(false)
      command = described_class.new('test_get_variable')
      expect { command.use('beef.net.nonexistent') }.to raise_error(/Invalid beefjs component/)
    end

    it 'does not add component twice' do
      component_path = "#{$root_dir}/core/main/client//net/local.js"
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(component_path).and_return(true)
      command = described_class.new('test_get_variable')
      command.use('beef.net.local')
      command.use('beef.net.local')
      expect(command.beefjs_components.keys.count).to eq(1)
    end
  end

  describe '#oc_value' do
    it 'returns option value when option exists' do
      BeEF::Core::Models::OptionCache.create!(name: 'test_option', value: 'test_value')
      command = described_class.new('test_get_variable')
      expect(command.oc_value('test_option')).to eq('test_value')
    end

    it 'returns nil when option does not exist' do
      command = described_class.new('test_get_variable')
      expect(command.oc_value('nonexistent')).to be_nil
    end
  end

  describe '#apply_defaults' do
    it 'applies option cache values to datastore' do
      BeEF::Core::Models::OptionCache.create!(name: 'option1', value: 'cached_value')
      command = described_class.new('test_get_variable')
      command.instance_variable_set(:@datastore, [{ 'name' => 'option1', 'value' => 'default_value' }])
      command.apply_defaults
      expect(command.datastore[0]['value']).to eq('cached_value')
    end

    it 'keeps default value when option cache does not exist' do
      command = described_class.new('test_get_variable')
      command.instance_variable_set(:@datastore, [{ 'name' => 'option1', 'value' => 'default_value' }])
      command.apply_defaults
      expect(command.datastore[0]['value']).to eq('default_value')
    end
  end
end
