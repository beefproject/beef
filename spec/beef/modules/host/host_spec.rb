#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Unit tests for every module under modules/host/.
# Each directory is tested for .options (when present), #pre_send, and #post_execute.
# Branch coverage: extra post_execute runs for modules listed in BRANCH_COVERAGE.
#

require_relative '../../../spec_helper'

project_root = File.expand_path('../../../../', __dir__)
host_module_paths = Dir[File.join(project_root, 'modules/host/**/module.rb')].sort

# Per-module datastore + config stubs to hit conditional branches in post_execute (e.g. NetworkService/NetworkHost path).
BRANCH_COVERAGE = {
  'modules/host/detect_cups' => {
    datastore: { 'results' => 'proto=http&ip=1.2.3.4&port=631&cups=Installed', 'beefhook' => '1', 'result' => '', 'cid' => '0' },
    config_get: { 'beef.extension.network.enable' => true }
  },
  'modules/host/detect_airdroid' => {
    datastore: { 'results' => 'proto=http&ip=1.2.3.4&port=8888&airdroid=Installed', 'airdroid' => '', 'beefhook' => '1', 'result' => '', 'cid' => '0' },
    config_get: { 'beef.extension.network.enable' => true }
  },
  'modules/host/get_internal_ip_java' => {
    datastore: { 'results' => '192.168.1.1', 'Result' => '', 'result' => '', 'beefhook' => '1', 'cid' => '0' },
    config_get: { 'beef.extension.network.enable' => true }
  },
  'modules/host/get_internal_ip_webrtc' => {
    datastore: { 'results' => 'IP is 192.168.1.1', 'Result' => '', 'result' => '', 'beefhook' => '1', 'cid' => '0' },
    config_get: { 'beef.extension.network.enable' => true }
  }
}.freeze

host_module_paths.each do |path|
  rel = path.sub("#{project_root}/", '').sub(/\.rb$/, '')
  branch_key = File.dirname(path).sub("#{project_root}/", '')
  require_path = File.join('../../../../', rel)
  class_line = File.read(path).lines.find { |l| l =~ /\bclass\s+(\w+)\s+<\s+BeEF::Core::Command/ }
  next unless class_line

  klass_name = class_line.match(/\bclass\s+(\w+)\s+<\s+BeEF::Core::Command/)[1]
  require_relative require_path
  mod = Object.const_get(klass_name)

  RSpec.describe mod do
    describe '.options' do
      it 'returns an Array when defined' do
        next unless described_class.respond_to?(:options)

        config = instance_double(BeEF::Core::Configuration)
        allow(config).to receive(:beef_host).and_return('127.0.0.1')
        allow(config).to receive(:beef_url_str).and_return('http://127.0.0.1:3000')
        allow(config).to receive(:get).with(anything).and_return('127.0.0.1')
        allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)

        opts = described_class.options
        expect(opts).to be_an(Array)
      end
    end

    describe '#pre_send' do
      it 'runs without error when defined' do
        next unless described_class.method_defined?(:pre_send)

        handler = instance_double('AssetHandler')
        allow(handler).to receive(:unbind).and_return(nil)
        allow(handler).to receive(:bind).and_return(nil)
        allow(handler).to receive(:bind_raw).and_return(nil)
        allow(handler).to receive(:remap).and_return(nil)
        allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
        config = instance_double(BeEF::Core::Configuration)
        allow(config).to receive(:get).with(anything).and_return('127.0.0.1')
        allow(config).to receive(:beef_host).and_return('127.0.0.1')
        allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
        instance = build_command_instance(described_class, 'result' => '', 'results' => '', 'cid' => '0')
        expect { run_pre_send(instance) }.not_to raise_error
      end
    end

    describe '#post_execute' do
      it 'runs without error when defined' do
        next unless described_class.method_defined?(:post_execute)

        handler = instance_double('AssetHandler')
        allow(handler).to receive(:unbind)
        allow(handler).to receive(:bind)
        allow(handler).to receive(:remap)
        allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)

        file_double = double('File', write: nil, close: nil)
        allow(File).to receive(:open).and_return(file_double)
        allow(BeEF::Core::Models::Command).to receive(:save_result)
        allow_any_instance_of(described_class).to receive(:ip).and_return('0.0.0.0')
        allow_any_instance_of(described_class).to receive(:timestamp).and_return('0')

        # Minimal datastore so modules that call .sub/.to_s on keys don't get nil
        instance = build_command_instance(described_class, 'result' => '', 'results' => '', 'cid' => '0')
        expect { run_post_execute(instance) }.not_to raise_error
      end

      it 'runs branch path when in BRANCH_COVERAGE' do
        branch = BRANCH_COVERAGE[branch_key]
        next unless described_class.method_defined?(:post_execute) && branch

        handler = instance_double('AssetHandler')
        allow(handler).to receive(:unbind)
        allow(handler).to receive(:bind)
        allow(handler).to receive(:remap)
        allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
        file_double = double('File', write: nil, close: nil)
        allow(File).to receive(:open).and_return(file_double)
        allow(BeEF::Core::Models::Command).to receive(:save_result)
        allow_any_instance_of(described_class).to receive(:ip).and_return('0.0.0.0')
        allow_any_instance_of(described_class).to receive(:timestamp).and_return('0')
        allow(BeEF::Core::Models::NetworkService).to receive(:create)
        allow(BeEF::Core::Models::NetworkHost).to receive(:create)
        allow(BeEF::Core::Models::BrowserDetails).to receive(:get).and_return('Linux')
        allow(BeEF::Filters).to receive(:is_valid_ip?).and_return(true)

        config = instance_double(BeEF::Core::Configuration)
        allow(config).to receive(:beef_host).and_return('127.0.0.1')
        allow(config).to receive(:beef_url_str).and_return('http://127.0.0.1:3000')
        allow(config).to receive(:get).with(anything) do |key|
          branch[:config_get].key?(key) ? branch[:config_get][key] : '127.0.0.1'
        end
        allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)

        instance = build_command_instance(described_class, branch[:datastore])
        expect { run_post_execute(instance) }.not_to raise_error
      end
    end
  end
end
