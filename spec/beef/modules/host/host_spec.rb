#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Unit tests for every module under modules/host/.
# Each directory is tested for .options (when present), #pre_send, and #post_execute.
# Branch coverage: extra post_execute runs for modules listed in
# BeefTestConfig.branch_coverage_for(:host) (defined in spec_helper.rb).
#

require_relative '../../../spec_helper'

project_root = File.expand_path('../../../../', __dir__)
host_module_paths = Dir[File.join(project_root, 'modules/host/**/module.rb')].sort

BRANCH_COVERAGE_HOST = BeefTestConfig.branch_coverage_for(:host)

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
    if described_class.respond_to?(:options)
      describe '.options' do
        it 'returns an Array' do
          config = instance_double(BeEF::Core::Configuration)
          allow(config).to receive(:beef_host).and_return('127.0.0.1')
          allow(config).to receive(:beef_url_str).and_return('http://127.0.0.1:3000')
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
          allow(config).to receive(:get).with(anything).and_return('127.0.0.1')
          allow(config).to receive(:beef_host).and_return('127.0.0.1')
          allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
          # Stub File.open so Hook_default_browser#pre_send doesn't read/write the real
          # bounce_to_ie_configured.pdf in modules/host/hook_default_browser/.
          # The source calls File.open(path, 'w') without a block and File.open(path, 'r') { |f| ... } with one.
          file_double = double('File').as_null_object
          allow(File).to receive(:open) do |*_args, &block|
            block ? block.call(file_double) : file_double
          end
          instance = build_command_instance(described_class, 'result' => '', 'results' => '', 'cid' => '0')
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

          # Minimal datastore so modules that call .sub/.to_s on keys don't get nil
          instance = build_command_instance(described_class, 'result' => '', 'results' => '', 'cid' => '0')
          expect { run_post_execute(instance) }.not_to raise_error
        end

        if BRANCH_COVERAGE_HOST[branch_key]
          it 'runs branch path with realistic datastore' do
            branch = BRANCH_COVERAGE_HOST[branch_key]

            # NetworkService / NetworkHost belong to the network extension and may not be
            # loaded during a modules-only spec run. Provide class doubles per-example
            # so `allow(...).to receive(:create)` resolves regardless.
            stub_const('BeEF::Core::Models::NetworkService', Class.new { def self.create(*); end }) unless defined?(BeEF::Core::Models::NetworkService)
            stub_const('BeEF::Core::Models::NetworkHost', Class.new { def self.create(*); end }) unless defined?(BeEF::Core::Models::NetworkHost)

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
  end
end
