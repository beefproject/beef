#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Core::Handlers::Commands do
  let(:mock_request) do
    double('request',
           params: { 'cid' => 123, 'beefhook' => 'test_session_id', 'results' => { 'data' => 'test' } },
           env: { 'HTTP_USER_AGENT' => 'Mozilla/5.0' })
  end

  let(:data) do
    {
      'request' => mock_request,
      'status' => 1,
      'results' => { 'data' => 'test' },
      'cid' => 123,
      'beefhook' => 'test_session_id'
    }
  end

  let(:mock_command_class) do
    Class.new do
      def initialize(_key)
        @friendlyname = 'Test Command'
      end

      attr_accessor :session_id

      def friendlyname
        @friendlyname
      end

      def build_callback_datastore(_result, _command_id, _beefhook, _http_params, _http_header); end

      def post_execute; end
    end
  end

  before do
    allow(BeEF::Core::Command).to receive(:const_get).and_return(mock_command_class)
    allow(BeEF::Module).to receive(:get_key_by_class).and_return('test_module')
    allow(BeEF::Core::Models::Command).to receive(:save_result).and_return(true)
  end

  describe '#initialize' do
    it 'initializes with data and class name' do
      handler = described_class.new(data, 'test')
      expect(handler.instance_variable_get(:@data)).to eq(data)
    end
  end

  describe '#get_param' do
    let(:handler) { described_class.new(data, 'test') }

    it 'returns value when key exists' do
      expect(handler.get_param(data, 'status')).to eq(1)
    end

    it 'returns nil when key does not exist' do
      expect(handler.get_param(data, 'nonexistent')).to be_nil
    end

    it 'returns nil when query is not a hash' do
      expect(handler.get_param('not a hash', 'key')).to be_nil
    end
  end

  describe '#setup' do
    context 'with valid parameters' do
      it 'processes command successfully' do
        allow(BeEF::Filters).to receive(:is_valid_hook_session_id?).and_return(true)
        handler = described_class.new(data, 'test')
        expect(BeEF::Core::Models::Command).to receive(:save_result).with(
          'test_session_id',
          123,
          'Test Command',
          { 'data' => { 'data' => 'test' } },
          1
        )
        handler.setup
      end
    end

    context 'with invalid command id' do
      let(:invalid_data) do
        {
          'request' => double('request', params: { 'cid' => 'not_an_integer' }, env: {}),
          'status' => 1,
          'results' => {}
        }
      end

      it 'returns early without saving' do
        handler = described_class.new(invalid_data, 'test')
        expect(BeEF::Core::Models::Command).not_to receive(:save_result)
        handler.setup
      end
    end

    context 'with invalid session id' do
      let(:invalid_data) do
        {
          'request' => double('request', params: { 'cid' => 123, 'beefhook' => 'invalid' }, env: {}),
          'status' => 1,
          'results' => {}
        }
      end

      it 'returns early without saving' do
        allow(BeEF::Filters).to receive(:is_valid_hook_session_id?).and_return(false)
        handler = described_class.new(invalid_data, 'test')
        expect(BeEF::Core::Models::Command).not_to receive(:save_result)
        handler.setup
      end
    end

    context 'with empty friendly name' do
      let(:empty_friendlyname_command) do
        Class.new do
          def initialize(_key)
            @friendlyname = ''
          end

          attr_accessor :session_id

          def friendlyname
            @friendlyname
          end

          def build_callback_datastore(_result, _command_id, _beefhook, _http_params, _http_header); end
        end
      end

      it 'returns early without saving' do
        allow(BeEF::Core::Command).to receive(:const_get).and_return(empty_friendlyname_command)
        allow(BeEF::Filters).to receive(:is_valid_hook_session_id?).and_return(true)
        handler = described_class.new(data, 'test')
        expect(BeEF::Core::Models::Command).not_to receive(:save_result)
        handler.setup
      end
    end

    context 'with invalid status' do
      let(:invalid_status_data) do
        {
          'request' => mock_request,
          'status' => 'not_an_integer',
          'results' => { 'data' => 'test' }
        }
      end

      it 'returns early without saving' do
        allow(BeEF::Filters).to receive(:is_valid_hook_session_id?).and_return(true)
        handler = described_class.new(invalid_status_data, 'test')
        expect(BeEF::Core::Models::Command).not_to receive(:save_result)
        handler.setup
      end
    end

    context 'with empty results' do
      let(:empty_results_data) do
        {
          'request' => mock_request,
          'status' => 1,
          'results' => {}
        }
      end

      it 'returns early without saving' do
        allow(BeEF::Filters).to receive(:is_valid_hook_session_id?).and_return(true)
        handler = described_class.new(empty_results_data, 'test')
        expect(BeEF::Core::Models::Command).not_to receive(:save_result)
        handler.setup
      end
    end
  end
end
