#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe 'BeEF Modules' do
  it 'loaded successfully' do
    config = BeEF::Core::Configuration.instance

    # Force reload modules to ensure fresh state
    BeEF::Modules.load

    # Verify modules were loaded
    all_modules = config.get('beef.module')
    expect(all_modules).not_to be_nil, 'Modules should be loaded'
    expect(all_modules).to be_a(Hash), 'Modules should be a hash'
    expect(all_modules.length).to be > 0, 'At least one module should be loaded'

    # Find enabled modules with categories
    modules = all_modules.select do |_k, v|
      v['enable'] == true && !v['category'].nil?
    end

    # Provide helpful error message if no enabled modules found
    if modules.empty?
      enabled_count = all_modules.count { |_k, v| v['enable'] == true }
      with_category = all_modules.count { |_k, v| !v['category'].nil? }
      raise "No enabled modules with categories found. Total modules: #{all_modules.length}, " \
            "Enabled: #{enabled_count}, With category: #{with_category}"
    end

    expect(modules.length).to be > 0, 'At least one enabled module with category should exist'

    modules.each_key do |k|
      expect(BeEF::Module.is_present(k)).to be(true)
      expect(BeEF::Module.is_enabled(k)).to be(true)

      # Skip hard_load if module file doesn't exist (e.g., test modules)
      mod_path = config.get("beef.module.#{k}.path")
      mod_file = "#{$root_dir}/#{mod_path}/module.rb" # rubocop:disable Style/GlobalVars
      if File.exist?(mod_file)
        expect do
          BeEF::Module.hard_load(k)
        end.to_not raise_error
        expect(BeEF::Module.is_loaded(k)).to be(true)
      end

      # Only check target if it exists
      target = config.get("beef.module.#{k}.target")
      next unless target.is_a?(Hash)

      target.each_value do |target_value|
        expect(target_value).to_not be_empty
      end
    end
  end

  it 'safe client debug log' do
    Dir['../../modules/**/*.js'].each do |path|
      next unless File.file?(path)

      File.open(path) do |f|
        f.grep(/\bconsole\.log\W*\(/m) do |line| # rubocop:disable Lint/UnreachableLoop -- false positive
          raise "Function 'console.log' instead of 'beef.debug' inside\n Path: #{path}\nLine: #{line}"
        end
      end
    end
  end

  it 'safe variable decleration' do
    Dir['../../modules/**/*.js'].each do |path|
      next unless File.file?(path)

      File.open(path) do |f|
        f.grep(/\blet\W+[a-zA-Z0-9_.]+\W*=/) do |line| # rubocop:disable Lint/UnreachableLoop -- false positive
          raise "Variable declared with 'let' instead of 'var' inside\n Path: #{path}\nLine: #{line}"
        end
      end
    end
  end
end
