#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Unit tests for every module under modules/ipec/.
#
# Some ipec modules reference BeEF::Extension::ETag and
# BeEF::Extension::ServerClientDnsTunnel which are not loaded in unit tests.
# We stub these per-example with stub_const so the stubs don't leak across
# the suite or shadow the real extensions when they happen to be loaded.
#

require_relative '../../../spec_helper'

project_root = File.expand_path('../../../../', __dir__)
paths = Dir[File.join(project_root, 'modules/ipec/**/module.rb')].sort

# Lightweight stand-ins for the extension singletons; no real behaviour required.
def stub_etag_messages_class
  Class.new do
    def self.instance
      @instance ||= Struct.new(:messages).new({})
    end
  end
end

def stub_dns_tunnel_server_class
  Class.new do
    def self.instance
      @instance ||= Struct.new(:messages).new({})
    end
  end
end

paths.each do |path|
  rel = path.sub("#{project_root}/", '').sub(/\.rb$/, '')
  require_path = File.join('../../../../', rel)
  class_line = File.read(path).lines.find { |l| l =~ /\bclass\s+(\w+)\s+<\s+BeEF::Core::Command/ }
  next unless class_line

  klass_name = class_line.match(/\bclass\s+(\w+)\s+<\s+BeEF::Core::Command/)[1]
  require_relative require_path
  mod = Object.const_get(klass_name)

  RSpec.describe mod do
    before(:each) do
      # Per-example stubs (auto-removed after each example).
      BeEF::Extension.const_set(:ETag, Module.new) unless BeEF::Extension.const_defined?(:ETag)
      BeEF::Extension.const_set(:ServerClientDnsTunnel, Module.new) unless BeEF::Extension.const_defined?(:ServerClientDnsTunnel)
      stub_const('BeEF::Extension::ETag::ETagMessages', stub_etag_messages_class) unless BeEF::Extension::ETag.const_defined?(:ETagMessages)
      stub_const('BeEF::Extension::ServerClientDnsTunnel::Server', stub_dns_tunnel_server_class) unless BeEF::Extension::ServerClientDnsTunnel.const_defined?(:Server)
    end

    if described_class.respond_to?(:options)
      describe '.options' do
        it 'returns an Array' do
          config = instance_double(BeEF::Core::Configuration)
          allow(config).to receive(:beef_host).and_return('127.0.0.1')
          allow(config).to receive(:beef_port).and_return('3000')
          allow(config).to receive(:beef_proto).and_return('http')
          allow(config).to receive(:get).with(anything).and_return('127.0.0.1')
          allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
          expect(described_class.options).to be_an(Array)
        end
      end
    end

    if described_class.method_defined?(:pre_send)
      describe '#pre_send' do
        it 'runs without error' do
          handler = instance_double('AssetHandler')
          allow(handler).to receive(:unbind).and_return(nil)
          allow(handler).to receive(:bind).and_return(nil)
          allow(handler).to receive(:bind_raw).and_return(nil)
          allow(handler).to receive(:remap).and_return(nil)
          allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
          config = instance_double(BeEF::Core::Configuration)
          allow(config).to receive(:get).with(anything) do |key|
            case key
            when 'beef.extension.etag.enable' then true
            when 'beef.extension.s2c_dns_tunnel.enable' then true
            when 'beef.extension.s2c_dns_tunnel.zone' then 'example.com'
            else '127.0.0.1'
            end
          end
          allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
          instance = build_command_instance(described_class, [{ 'name' => 'data', 'value' => 'test' }])
          expect { run_pre_send(instance) }.not_to raise_error
        end
      end
    end

    if described_class.method_defined?(:post_execute)
      describe '#post_execute' do
        it 'runs without error' do
          handler = instance_double('AssetHandler')
          allow(handler).to receive(:unbind)
          allow(handler).to receive(:bind)
          allow(handler).to receive(:remap)
          allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
          file_double = double('File').as_null_object
          allow(File).to receive(:open).and_return(file_double)
          allow(BeEF::Core::Models::Command).to receive(:save_result)
          allow_any_instance_of(described_class).to receive(:ip).and_return('0.0.0.0')
          allow_any_instance_of(described_class).to receive(:timestamp).and_return('0')
          instance = build_command_instance(described_class, 'result' => '', 'results' => '', 'cid' => '0')
          expect { run_post_execute(instance) }.not_to raise_error
        end
      end
    end
  end
end
