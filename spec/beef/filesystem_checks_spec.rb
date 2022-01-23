RSpec.describe 'BeEF Filesystem' do
  def file_test(file)
    expect(File.file?(file)).to be(true)
    expect(File.zero?(file)).to be(false)
  end

  it 'required files' do
    files = [
      'beef',
      'config.yaml',
      'install'
    ]
    files.each do |f|
      file_test(f)
    end
  end

  it 'executable directories' do
    dirs = [
      'core',
      'modules',
      'extensions'
    ]
    dirs.each do |d|
      expect(File.executable?(d)).to be(true)
    end
  end
end
