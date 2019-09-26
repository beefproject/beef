RSpec.describe 'BeEF Modules' do

  it 'loaded successfully' do
    expect {
      BeEF::Modules.load
    }.to_not raise_error

    modules = BeEF::Core::Configuration.instance.get('beef.module').select do |k,v|
      v['enable'] == true and v['category'] != nil
    end
    expect(modules.length).to be > 0

    modules.each do |k,v|
      expect(BeEF::Module.is_present(k)).to be(true)
      expect(BeEF::Module.is_enabled(k)).to be(true)
      expect {
        BeEF::Module.hard_load(k)
      }.to_not raise_error
      expect(BeEF::Module.is_loaded(k)).to be(true)
      BeEF::Core::Configuration.instance.get("beef.module.#{k}.target").each do |k,v|
        expect(v).to_not be_empty
      end
    end
  end

  it 'safe client debug log' do
    Dir['../../modules/**/*.js'].each do |path|
      next unless File.file?(path)
      File.open(path) do |f|
        f.grep(/\bconsole\.log\W*\(/m) do |line|
          fail "Function 'console.log' instead of 'beef.debug' inside\n Path: #{path}\nLine: #{line}"
        end
      end
    end
  end

  it 'safe variable decleration' do
    Dir['../../modules/**/*.js'].each do |path|
      next unless File.file?(path)
      File.open(path) do |f|
        f.grep(/\blet\W+[a-zA-Z0-9_\.]+\W*=/) do |line|
          fail "Variable declared with 'let' instead of 'var' inside\n Path: #{path}\nLine: #{line}"
        end
      end
    end
  end

end
