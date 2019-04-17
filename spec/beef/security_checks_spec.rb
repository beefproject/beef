RSpec.describe 'BeEF Security Checks' do

  it 'dangerous eval usage' do
    Dir['**/*.rb'].each do |path|
      File.open(path) do |f|
        next if /#{File.basename(__FILE__)}/.match(path) # skip this file
        next if /\/msf-test\//.match(path) # skip this file
        next if /extensions\/dns/.match(path) # skip this file

        f.grep(/\Weval\W/im) do |line|
          fail "Illegal use of 'eval' found in\n Path: #{path}\nLine:  #{line}"
        end
      end
    end
  end

end
