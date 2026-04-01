#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Unit tests for every module under modules/phonegap/.
# Some modules use #callback instead of #post_execute; only post_execute is tested here.
#

require_relative '../../../spec_helper'

project_root = File.expand_path('../../../../', __dir__)
paths = Dir[File.join(project_root, 'modules/phonegap/**/module.rb')].sort

paths.each do |path|
  rel = path.sub("#{project_root}/", '').sub(/\.rb$/, '')
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
        allow(config).to receive(:hook_file_path).and_return('/hook.js')
        allow(config).to receive(:get).with(anything).and_return('127.0.0.1')
        allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
        expect(described_class.options).to be_an(Array)
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
        instance = build_command_instance(described_class, 'result' => '', 'Result' => '', 'cid' => '0')
        expect { run_pre_send(instance) }.not_to raise_error
      end
    end

    describe '#post_execute' do
      it 'runs without error when defined' do
        next unless described_class.method_defined?(:post_execute)
        handler = instance_double('AssetHandler')
        allow(handler).to receive(:unbind)
        allow(handler).to receive(:bind)
        allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
        instance = build_command_instance(described_class, 'result' => '', 'Result' => '', 'cid' => '0')
        expect { run_post_execute(instance) }.not_to raise_error
      end
    end
  end
end
