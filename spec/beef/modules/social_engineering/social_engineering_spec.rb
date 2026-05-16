#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Unit tests for every module under modules/social_engineering/.
# Branch coverage: extra post_execute for KILLFRAME / conditional paths.
#

require_relative '../../../spec_helper'

project_root = File.expand_path('../../../../', __dir__)
paths = Dir[File.join(project_root, 'modules/social_engineering/**/module.rb')].sort

BRANCH_COVERAGE = {
  'modules/social_engineering/fake_lastpass' => { datastore: { 'meta' => 'KILLFRAME', 'result' => '', 'results' => '', 'answer' => '', 'cid' => '0' } },
  'modules/social_engineering/fake_evernote_clipper' => { datastore: { 'meta' => 'KILLFRAME', 'result' => '', 'results' => '', 'answer' => '', 'cid' => '0' } }
}.freeze

# Modules whose pre_send needs Zip, real filesystem, or logger; skip generic pre_send example
PRE_SEND_SKIP = %w[
  Firefox_extension_bindshell Firefox_extension_dropper Firefox_extension_reverse_shell
  Text_to_voice Ui_abuse_ie
].freeze

paths.each do |path|
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
        allow(config).to receive(:beef_proto).and_return('http')
        allow(config).to receive(:beef_port).and_return('3000')
        allow(config).to receive(:beef_url_str).and_return('http://127.0.0.1:3000')
        allow(config).to receive(:get).with(anything) do |key|
          key == 'beef.module.simple_hijacker.templates' ? [] : '127.0.0.1'
        end
        allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
        expect(described_class.options).to be_an(Array)
      end
    end

    describe '#pre_send' do
      it 'runs without error when defined' do
        next unless described_class.method_defined?(:pre_send)
        next if PRE_SEND_SKIP.include?(described_class.name)

        handler = instance_double('AssetHandler')
        allow(handler).to receive(:unbind).and_return(nil)
        allow(handler).to receive(:bind).and_return(nil)
        allow(handler).to receive(:bind_raw).with(anything, anything, anything, anything, anything).and_return(nil)
        allow(handler).to receive(:remap).and_return(nil)
        allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
        config = instance_double(BeEF::Core::Configuration)
        allow(config).to receive(:get).with(anything).and_return('127.0.0.1')
        allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
        allow(IO).to receive(:popen).and_return(StringIO.new(''))
        # Many pre_send implementations expect @datastore to be an Array of option hashes (name/value)
        pre_send_datastore = [
          { 'name' => 'payload', 'value' => 'cmd' },
          { 'name' => 'payload_handler', 'value' => 'http://127.0.0.1:8080' },
          { 'name' => 'extension_name', 'value' => 'TestExt' },
          { 'name' => 'xpi_name', 'value' => 'test.xpi' },
          { 'name' => 'lport', 'value' => '4444' }
        ]
        instance = build_command_instance(described_class, pre_send_datastore)
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
        instance = build_command_instance(described_class, 'result' => '', 'results' => '', 'answer' => '', 'cid' => '0')
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
        instance = build_command_instance(described_class, branch[:datastore])
        expect { run_post_execute(instance) }.not_to raise_error
      end
    end
  end
end
