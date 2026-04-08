#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Unit tests for every module under modules/network/ (including ADC).
#

require_relative '../../../spec_helper'

# Stub Dns extension only when the real one is not loaded (e.g. rake coverage:modules).
# If we stub when the real extension loads later (e.g. dns_spec), we get "superclass mismatch for class Server".
# When the real Dns is already loaded (rake short), we stub Server.instance in the pre_send example instead.
unless BeEF::Extension.const_defined?(:Dns)
  BeEF::Extension.const_set(:Dns, Module.new)
  dns_server_instance = Object.new
  def dns_server_instance.add_rule(*) 1 end
  def dns_server_instance.remove_rule!(*) nil end
  dns_server = Class.new do
    define_singleton_method(:instance) { dns_server_instance }
  end
  BeEF::Extension::Dns.const_set(:Server, dns_server)
end

# Per-module datastore + config to hit conditional branches in post_execute (network extension + regex paths).
BRANCH_COVERAGE = {
  'modules/network/port_scanner' => {
    datastore: { 'results' => 'ip=1.2.3.4&port=HTTP: Port 80 is OPEN Apache', 'beefhook' => '1', 'result' => '', 'port' => '', 'cid' => '0' },
    config_get: { 'beef.extension.network.enable' => true }
  },
  'modules/network/ping_sweep' => {
    datastore: { 'results' => 'ip=192.168.1.1&ping=10ms', 'beefhook' => '1', 'result' => '', 'cid' => '0' },
    config_get: { 'beef.extension.network.enable' => true }
  },
  'modules/network/ping_sweep_ff' => {
    datastore: { 'results' => 'host=192.168.1.1 is alive', 'beefhook' => '1', 'result' => '', 'host' => '', 'cid' => '0' },
    config_get: { 'beef.extension.network.enable' => true }
  },
  'modules/network/get_http_servers' => {
    datastore: { 'results' => 'proto=http&ip=1.2.3.4&port=80&url=http://1.2.3.4/', 'beefhook' => '1', 'result' => '', 'url' => '', 'cid' => '0' },
    config_get: { 'beef.extension.network.enable' => true }
  },
  'modules/network/cross_origin_scanner_cors' => {
    datastore: { 'results' => 'proto=http&ip=1.2.3.4&port=80&status=200', 'beefhook' => '1', 'result' => '', 'cid' => '0' },
    config_get: { 'beef.extension.network.enable' => true }
  },
  'modules/network/detect_burp' => {
    datastore: { 'results' => 'has_burp=true&response=PROXY 127.0.0.1:8080', 'beefhook' => '1', 'result' => '', 'cid' => '0' },
    config_get: { 'beef.extension.network.enable' => true }
  },
  'modules/network/get_ntop_network_hosts' => {
    datastore: { 'results' => 'proto=http&ip=1.2.3.4&port=3000&data={"hostNumIpAddress":"192.168.1.1"}', 'beefhook' => '1', 'result' => '', 'cid' => '0' },
    config_get: { 'beef.extension.network.enable' => true }
  },
  'modules/network/internal_network_fingerprinting' => {
    datastore: { 'results' => 'proto=http&ip=1.2.3.4&port=80&discovered=Apache&url=http://test/', 'beefhook' => '1', 'result' => '', 'discovered' => '', 'url' => '', 'cid' => '0' },
    config_get: { 'beef.extension.network.enable' => true }
  },
  'modules/network/get_proxy_servers_wpad' => [
    { datastore: { 'results' => 'proxies=PROXY 192.168.1.1:3128', 'beefhook' => '1', 'result' => '', 'cid' => '0' }, config_get: { 'beef.extension.network.enable' => true } },
    { datastore: { 'results' => 'proxies=SOCKS 192.168.1.1:1080', 'beefhook' => '1', 'result' => '', 'cid' => '0' }, config_get: { 'beef.extension.network.enable' => true } }
  ],
  'modules/network/jslanscanner' => [
    { datastore: { 'results' => 'proto=http&ip=1.2.3.4&port=80&service=HTTP', 'beefhook' => '1', 'result' => '', 'cid' => '0' }, config_get: { 'beef.extension.network.enable' => true } },
    { datastore: { 'results' => 'ip=1.2.3.4&device=Router', 'beefhook' => '1', 'result' => '', 'cid' => '0' }, config_get: { 'beef.extension.network.enable' => true } }
  ],
  'modules/network/fetch_port_scanner' => {
    datastore: { 'result' => 'ok', 'beefhook' => '1', 'cid' => '0' },
    config_get: { 'beef.extension.network.enable' => true }
  },
  'modules/network/cross_origin_scanner_flash' => [
    { datastore: { 'results' => 'ip=1.2.3.4&status=alive', 'result' => '', 'beefhook' => '1', 'cid' => '0' }, config_get: { 'beef.extension.network.enable' => true } },
    { datastore: { 'results' => 'proto=http&ip=1.2.3.4&port=80&title=Apache', 'result' => '', 'beefhook' => '1', 'cid' => '0' }, config_get: { 'beef.extension.network.enable' => true } }
  ]
}.freeze

project_root = File.expand_path('../../../../', __dir__)
paths = Dir[File.join(project_root, 'modules/network/**/module.rb')].sort

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
    # Irc_nat_pinning calls sleep 30 in post_execute; stub so the suite doesn't block.
    before(:each) do
      allow(Kernel).to receive(:sleep)
      allow_any_instance_of(described_class).to receive(:sleep).and_return(nil)
    end

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

    describe '#pre_send' do
      it 'runs without error when defined' do
        next unless described_class.method_defined?(:pre_send)
        # When real Dns extension is loaded (rake short), stub Server.instance so Dns_rebinding works
        if BeEF::Extension.const_defined?(:Dns) && BeEF::Extension::Dns.const_defined?(:Server)
          dns_instance = double('DnsServer', add_rule: 1, remove_rule!: nil)
          allow(BeEF::Extension::Dns::Server).to receive(:instance).and_return(dns_instance)
        end
        handler = instance_double('AssetHandler')
        allow(handler).to receive(:unbind).and_return(nil)
        allow(handler).to receive(:bind).and_return(nil)
        allow(handler).to receive(:bind_raw).and_return(nil)
        allow(handler).to receive(:bind_socket).and_return(nil)
        allow(handler).to receive(:unbind_socket).and_return(nil)
        allow(handler).to receive(:bind_cached).and_return(nil)
        allow(handler).to receive(:remap).and_return(nil)
        allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
        config = instance_double(BeEF::Core::Configuration)
        allow(config).to receive(:get).with(anything) do |key|
          case key
          when 'beef.extension.dns_rebinding' then { 'address_http_external' => '127.0.0.1', 'port_proxy' => '1234' }
          when 'beef.module.dns_rebinding.domain' then 'example.com'
          else '127.0.0.1'
          end
        end
        allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
        # Dns_rebinding expects @datastore as Array of option hashes (target, domain, url_callback)
        datastore = described_class.name.include?('Dns_rebinding') ? [{ 'value' => '192.168.0.1' }, { 'value' => 'example.com' }, {}] : { 'result' => '', 'results' => '', 'cid' => '0' }
        instance = build_command_instance(described_class, datastore)
        expect { run_pre_send(instance) }.not_to raise_error
      end
    end

    describe '#post_execute' do
      it 'runs without error when defined' do
        next unless described_class.method_defined?(:post_execute)
        handler = instance_double('AssetHandler')
        allow(handler).to receive(:unbind)
        allow(handler).to receive(:bind)
        allow(handler).to receive(:bind_socket)
        allow(handler).to receive(:unbind_socket)
        allow(handler).to receive(:remap)
        allow(handler).to receive(:bind_cached)
        allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
        file_double = double('File', write: nil, close: nil)
        allow(File).to receive(:open).and_return(file_double)
        allow(BeEF::Core::Models::Command).to receive(:save_result)
        allow_any_instance_of(described_class).to receive(:ip).and_return('0.0.0.0')
        allow_any_instance_of(described_class).to receive(:timestamp).and_return('0')
        allow(Kernel).to receive(:sleep)
        instance = build_command_instance(described_class, 'result' => '', 'results' => '', 'cid' => '0')
        expect { run_post_execute(instance) }.not_to raise_error
      end

      it 'runs branch path when in BRANCH_COVERAGE' do
        raw = BRANCH_COVERAGE[branch_key]
        next unless described_class.method_defined?(:post_execute) && raw

        branches = raw.is_a?(Array) ? raw : [raw]
        branches.each do |branch|
          handler = instance_double('AssetHandler')
          allow(handler).to receive(:unbind)
          allow(handler).to receive(:bind)
          allow(handler).to receive(:bind_socket)
          allow(handler).to receive(:unbind_socket)
          allow(handler).to receive(:remap)
          allow(handler).to receive(:bind_cached)
          allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
          file_double = double('File', write: nil, close: nil)
          allow(File).to receive(:open).and_return(file_double)
          allow(BeEF::Core::Models::Command).to receive(:save_result)
          allow_any_instance_of(described_class).to receive(:ip).and_return('0.0.0.0')
          allow_any_instance_of(described_class).to receive(:timestamp).and_return('0')
          allow(Kernel).to receive(:sleep)
          allow(BeEF::Core::Models::NetworkService).to receive(:create)
          allow(BeEF::Core::Models::NetworkHost).to receive(:create)
          allow(BeEF::Filters).to receive(:is_valid_ip?).and_return(true)

          config = instance_double(BeEF::Core::Configuration)
          allow(config).to receive(:beef_host).and_return('127.0.0.1')
          allow(config).to receive(:beef_port).and_return('3000')
          allow(config).to receive(:beef_proto).and_return('http')
          allow(config).to receive(:get).with(anything) do |key|
            branch[:config_get] && branch[:config_get].key?(key) ? branch[:config_get][key] : '127.0.0.1'
          end
          allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)

          instance = build_command_instance(described_class, branch[:datastore])
          expect { run_post_execute(instance) }.not_to raise_error
        end
      end
    end
  end
end
