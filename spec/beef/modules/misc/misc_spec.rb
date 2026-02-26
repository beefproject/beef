#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Unit tests for every module under modules/misc/ (including subdirs).
# Branch coverage: extra post_execute runs for modules in BRANCH_COVERAGE.
#

require_relative '../../../spec_helper'

project_root = File.expand_path('../../../../', __dir__)
paths = Dir[File.join(project_root, 'modules/misc/**/module.rb')].sort

BRANCH_COVERAGE = {
  'modules/misc/wordpress_post_auth_rce' => { datastore: { 'result' => 'ok', 'cid' => '0' } }
}.freeze

paths.each do |path|
  rel = path.sub("#{project_root}/", '').sub(/\.rb$/, '')
  branch_key = File.dirname(path).sub("#{project_root}/", '')
  require_path = File.join('../../../../', rel)
  class_line = File.read(path).lines.find { |l| l =~ /\bclass\s+(\w+)\s+<\s+(?:\w+|BeEF::\w+(?:::\w+)*)/ }
  next unless class_line

  klass_name = class_line.match(/\bclass\s+(\w+)\s+<\s+(?:\w+|BeEF::\w+(?:::\w+)*)/)[1]
  require_relative require_path
  mod = Object.const_get(klass_name)

  RSpec.describe mod do
    describe '.options' do
      it 'returns an Array when defined' do
        next unless described_class.respond_to?(:options)

        config = instance_double(BeEF::Core::Configuration)
        allow(config).to receive(:beef_host).and_return('127.0.0.1')
        allow(config).to receive(:beef_port).and_return('3000')
        allow(config).to receive(:beef_proto).and_return('http')
        allow(config).to receive(:get).with(anything).and_return('127.0.0.1')
        allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
        expect(described_class.options).to be_an(Array)
      end
    end

    # Specific test for Wordpress_add_user to ensure options method executes fully
    if klass_name == 'Wordpress_add_user'
      describe '.options' do
        it 'includes wordpress path and user options' do
          config = instance_double(BeEF::Core::Configuration)
          allow(config).to receive(:beef_host).and_return('127.0.0.1')
          allow(config).to receive(:beef_port).and_return('3000')
          allow(config).to receive(:beef_proto).and_return('http')
          allow(config).to receive(:get).with(anything).and_return('127.0.0.1')
          allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)

          options = described_class.options
          expect(options).to be_an(Array)
          expect(options.length).to eq(6) # wp_path + 5 user options

          # Check that wp_path option exists (from parent)
          wp_path_option = options.find { |opt| opt['name'] == 'wp_path' }
          expect(wp_path_option).to be_present
          expect(wp_path_option['value']).to eq('/')

          # Check that username option exists
          username_option = options.find { |opt| opt['name'] == 'username' }
          expect(username_option).to be_present
          expect(username_option['value']).to eq('beef')

          # Check that password option exists and has a generated value
          password_option = options.find { |opt| opt['name'] == 'password' }
          expect(password_option).to be_present
          expect(password_option['value']).to be_a(String)
          expect(password_option['value'].length).to eq(10) # SecureRandom.hex(5) = 10 chars
        end
      end
    end

    # Specific test for Test_get_variable to ensure options method executes fully
    if klass_name == 'Test_get_variable'
      describe '.options' do
        it 'returns payload_name option with correct structure' do
          config = instance_double(BeEF::Core::Configuration)
          allow(config).to receive(:beef_host).and_return('127.0.0.1')
          allow(config).to receive(:beef_port).and_return('3000')
          allow(config).to receive(:beef_proto).and_return('http')
          allow(config).to receive(:get).with(anything).and_return('127.0.0.1')
          allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)

          options = described_class.options
          expect(options).to be_an(Array)
          expect(options.length).to eq(1)

          option = options.first
          expect(option['name']).to eq('payload_name')
          expect(option['ui_label']).to eq('Payload Name')
          expect(option['type']).to eq('text')
          expect(option['value']).to eq('message')
          expect(option['width']).to eq('400px')
        end
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
        allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
        allow(IO).to receive(:popen).and_return(StringIO.new(''))
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
        allow(handler).to receive(:bind_raw)
        allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
        file_double = double('File', write: nil, close: nil)
        allow(File).to receive(:open).and_return(file_double)
        allow(BeEF::Core::Models::Command).to receive(:save_result)
        allow_any_instance_of(described_class).to receive(:ip).and_return('0.0.0.0')
        allow_any_instance_of(described_class).to receive(:timestamp).and_return('0')
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
        allow(handler).to receive(:bind_raw)
        allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
        file_double = double('File', write: nil, close: nil)
        allow(File).to receive(:open).and_return(file_double)
        allow(BeEF::Core::Models::Command).to receive(:save_result)
        allow_any_instance_of(described_class).to receive(:ip).and_return('0.0.0.0')
        allow_any_instance_of(described_class).to receive(:timestamp).and_return('0')
        instance = build_command_instance(described_class, branch[:datastore])
        expect { run_post_execute(instance) }.not_to raise_error
      end
    end
  end
end
