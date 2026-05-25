#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Unit tests for every module under modules/network/ (including ADC).
#
# Branch coverage data lives in BeefTestConfig.branch_coverage_for(:network)
# (see spec_helper.rb). Per-example stub_const calls inject a Dns::Server
# stand-in only when the real Dns extension is not loaded, avoiding the
# "superclass mismatch for class Server" hazard that arises if the stub
# leaks into the suite before the real extension's spec loads.
#

require_relative '../../../spec_helper'

BRANCH_COVERAGE_NETWORK = BeefTestConfig.branch_coverage_for(:network)

# Lightweight Dns server stand-in used when the real BeEF::Extension::Dns is
# not loaded (e.g. when running modules-only specs).
DNS_SERVER_STUB = Class.new do
  def self.instance
    @instance ||= Object.new.tap do |o|
      def o.add_rule(*) 1 end
      def o.remove_rule!(*) nil end
    end
  end
end

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
    before(:each) do
      # Irc_nat_pinning calls sleep 30 in post_execute; suppress so the suite doesn't block.
      allow(Kernel).to receive(:sleep)
      allow_any_instance_of(described_class).to receive(:sleep).and_return(nil)

      # Provide a per-example Dns::Server stand-in only if the real extension hasn't been loaded.
      # Using stub_const keeps the stub scoped to this example only.
      unless defined?(BeEF::Extension::Dns) && BeEF::Extension::Dns.const_defined?(:Server)
        BeEF::Extension.const_set(:Dns, Module.new) unless BeEF::Extension.const_defined?(:Dns)
        stub_const('BeEF::Extension::Dns::Server', DNS_SERVER_STUB)
      end
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
          # If the real Dns extension is loaded (e.g. rake short), stub Server.instance so Dns_rebinding works.
          if defined?(BeEF::Extension::Dns) && BeEF::Extension::Dns.const_defined?(:Server)
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
          # Dns_rebinding expects @datastore as Array of option hashes (target, domain, url_callback).
          datastore = described_class.name.include?('Dns_rebinding') ? [{ 'value' => '192.168.0.1' }, { 'value' => 'example.com' }, {}] : { 'result' => '', 'results' => '', 'cid' => '0' }
          instance = build_command_instance(described_class, datastore)
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
          allow(handler).to receive(:bind_socket)
          allow(handler).to receive(:unbind_socket)
          allow(handler).to receive(:remap)
          allow(handler).to receive(:bind_cached)
          allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
          file_double = double('File').as_null_object
          allow(File).to receive(:open).and_return(file_double)
          allow(BeEF::Core::Models::Command).to receive(:save_result)
          allow_any_instance_of(described_class).to receive(:ip).and_return('0.0.0.0')
          allow_any_instance_of(described_class).to receive(:timestamp).and_return('0')
          instance = build_command_instance(described_class, 'result' => '', 'results' => '', 'cid' => '0')
          expect { run_post_execute(instance) }.not_to raise_error
        end

        if BRANCH_COVERAGE_NETWORK[branch_key]
          it 'runs branch path with realistic datastore' do
            raw = BRANCH_COVERAGE_NETWORK[branch_key]
            branches = raw.is_a?(Array) ? raw : [raw]

            # NetworkService / NetworkHost belong to the network extension and may not be
            # loaded during a modules-only spec run. Provide class doubles per-example
            # so `allow(...).to receive(:create)` resolves regardless.
            stub_const('BeEF::Core::Models::NetworkService', Class.new { def self.create(*); end }) unless defined?(BeEF::Core::Models::NetworkService)
            stub_const('BeEF::Core::Models::NetworkHost', Class.new { def self.create(*); end }) unless defined?(BeEF::Core::Models::NetworkHost)

            branches.each do |branch|
              handler = instance_double('AssetHandler')
              allow(handler).to receive(:unbind)
              allow(handler).to receive(:bind)
              allow(handler).to receive(:bind_socket)
              allow(handler).to receive(:unbind_socket)
              allow(handler).to receive(:remap)
              allow(handler).to receive(:bind_cached)
              allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
              file_double = double('File').as_null_object
              allow(File).to receive(:open).and_return(file_double)
              allow(BeEF::Core::Models::Command).to receive(:save_result)
              allow_any_instance_of(described_class).to receive(:ip).and_return('0.0.0.0')
              allow_any_instance_of(described_class).to receive(:timestamp).and_return('0')
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
  end
end
