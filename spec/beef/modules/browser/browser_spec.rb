#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Unit tests for every module under modules/browser/ (including hooked_origin).
# Branch coverage: extra post_execute for modules that set BrowserDetails when results match.
#

require_relative '../../../spec_helper'

project_root = File.expand_path('../../../../', __dir__)
browser_module_paths = Dir[File.join(project_root, 'modules/browser/**/module.rb')].sort

# Load branch coverage data from centralised config
BRANCH_COVERAGE_BROWSER = BeefTestConfig.branch_coverage_for(:browser)

browser_module_paths.each do |path|
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
          allow(config).to receive(:beef_proto).and_return('http')
          allow(config).to receive(:beef_port).and_return('3000')
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
          allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
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
          allow(handler).to receive(:bind_raw)
          allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
          # Some modules (e.g. Spyder_eye) write screenshot files to $home_dir on the success path.
          # Stub File.open with a block-aware double so the test never touches the real filesystem.
          file_double = double('File').as_null_object
          allow(File).to receive(:open) do |*_args, &block|
            block ? block.call(file_double) : file_double
          end

          instance = build_command_instance(described_class, 'result' => '', 'results' => '', 'cid' => '0')
          expect { run_post_execute(instance) }.not_to raise_error
        end

        if BRANCH_COVERAGE_BROWSER[branch_key]
          it 'runs branch path with realistic datastore' do
            branch = BRANCH_COVERAGE_BROWSER[branch_key]

            handler = instance_double('AssetHandler')
            allow(handler).to receive(:unbind)
            allow(handler).to receive(:bind)
            allow(handler).to receive(:remap)
            allow(handler).to receive(:bind_raw)
            allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
            allow(BeEF::Core::Models::BrowserDetails).to receive(:set)
            instance = build_command_instance(described_class, branch[:datastore])
            expect { run_post_execute(instance) }.not_to raise_error
          end
        end
      end
    end
  end
end
