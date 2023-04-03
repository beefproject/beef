#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'yaml'
require 'bundler/setup'
load 'tasks/otr-activerecord.rake'
#require 'pry-byebug'


task :default => ["spec"]

desc 'Generate API documentation to doc/rdocs/index.html'
task :rdoc do
  Rake::Task['rdoc:rerdoc'].invoke
end

## RSPEC
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--tag ~run_on_browserstack']
end

RSpec::Core::RakeTask.new(:browserstack) do |task|
  task.rspec_opts = ['--tag run_on_browserstack']
end

RSpec::Core::RakeTask.new(:bs) do |task|
  configs = Dir["spec/support/browserstack/**/*.yml"]
  configs.each do |config|
    config = config.split('spec/support/browserstack')[1]
    ENV['CONFIG_FILE'] = config
    puts "\e[45m#{config.upcase}\e[0m"
    task.rspec_opts = ['--tag run_on_browserstack']
    Rake::Task['browserstack'].invoke
    Rake::Task['browserstack'].reenable
  end
end

################################
# SSL/TLS certificate

namespace :ssl do
  desc 'Create a new SSL certificate'
  task :create do
    if File.file?('beef_key.pem')
      puts 'Certificate already exists. Replace? [Y/n]'
      confirm = STDIN.getch.chomp
      unless confirm.eql?('') || confirm.downcase.eql?('y')
        puts "Aborted"
        exit 1
      end
    end
    Rake::Task['ssl:replace'].invoke
  end

  desc 'Re-generate SSL certificate'
  task :replace do
    if File.file?('/usr/local/bin/openssl')
      path = '/usr/local/bin/openssl'
    elsif File.file?('/usr/bin/openssl')
      path = '/usr/bin/openssl'
    else
      puts "[-] Error: could not find openssl"
      exit 1
    end
    IO.popen([path, 'req', '-new', '-newkey', 'rsa:4096', '-sha256', '-x509', '-days', '3650', '-nodes', '-out', 'beef_cert.pem', '-keyout', 'beef_key.pem', '-subj', '/CN=localhost'], 'r+').read.to_s
  end
end

################################
# rdoc

namespace :rdoc do
  require 'rdoc/task'

  desc 'Generate API documentation to doc/rdocs/index.html'
  Rake::RDocTask.new do |rd|
    rd.rdoc_dir = 'doc/rdocs'
    rd.main = 'README.mkd'
    rd.rdoc_files.include('core/**/*\.rb')
      #'extensions/**/*\.rb'
      #'modules/**/*\.rb'
    rd.options << '--line-numbers'
    rd.options << '--all'
  end
end

################################
# X11 set up

@xserver_process_id = nil;

task :xserver_start do
  printf "Starting X11 Server (wait 10 seconds)..."
  @xserver_process_id = IO.popen("/usr/bin/Xvfb :0 -screen 0 1024x768x24 2> /dev/null", "w+")
  delays = [2, 2, 1, 1, 1, 0.5, 0.5, 0.5, 0.3, 0.2, 0.1, 0.1, 0.1, 0.05, 0.05]
  delays.each do |i| # delay for 10 seconds
    printf '.'
    sleep (i) # increase the . display rate
  end
  puts '.'
end

task :xserver_stop do
  puts "\nShutting down X11 Server...\n"
  sh "ps -ef|grep Xvfb|grep -v grep|grep -v rake|awk '{print $2}'|xargs kill"
end

################################
# BeEF environment set up

@beef_process_id = nil;
@beef_config_file = 'tmp/rk_beef_conf.yaml';


task :beef_start => 'beef' do
  # read environment param for creds or use bad_fred
  test_user = ENV['TEST_BEEF_USER'] || 'bad_fred'
  test_pass = ENV['TEST_BEEF_PASS'] || 'bad_fred_no_access'

  # write a rake config file for beef
  config = YAML.safe_load(File.read('./config.yaml'))
  config['beef']['credentials']['user'] = test_user
  config['beef']['credentials']['passwd'] = test_pass
  Dir.mkdir('tmp') unless Dir.exist?('tmp')
  File.open(@beef_config_file, 'w') { |f| YAML.dump(config, f) }

  # set the environment creds -- in case we're using bad_fred
  ENV['TEST_BEEF_USER'] = test_user
  ENV['TEST_BEEF_PASS'] = test_pass
  config = nil
  puts "Using config file: #{@beef_config_file}\n"

  printf "Starting BeEF (wait a few seconds)..."
  @beef_process_id = IO.popen("ruby ./beef -c #{@beef_config_file} -x 2> /dev/null", "w+")
  delays = [5, 5, 5, 4, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  delays.each do |i| # delay for a few seconds
    printf '.'
    sleep (i)
  end
  puts ".\n\n"
end

task :beef_stop do
  # cleanup tmp/config files
  puts "\nCleanup config file:\n"
  rm_f @beef_config_file
  ENV['TEST_BEEF_USER'] = nil
  ENV['TEST_BEEF_PASS'] = nil

  # shutting down
  puts "Shutting down BeEF...\n"
  sh "ps -ef|grep beef|grep -v grep|grep -v rake|awk '{print $2}'|xargs kill"
end

################################
# MSF environment set up

@msf_process_id = nil;

task :msf_start => '/tmp/msf-test/msfconsole' do
  printf "Starting MSF (wait 45 seconds)..."
  @msf_process_id = IO.popen("/tmp/msf-test/msfconsole -r test/thirdparty/msf/unit/BeEF.rc 2> /dev/null", "w+")
  delays = [10, 7, 6, 5, 4, 3, 2, 2, 1, 1, 1, 0.5, 0.5, 0.5, 0.3, 0.2, 0.1, 0.1, 0.1, 0.05, 0.05]
  delays.each do |i| # delay for 45 seconds
    printf '.'
    sleep (i) # increase the . display rate
  end
  puts '.'
end

task :msf_stop do
  puts "\nShutting down MSF...\n"
  @msf_process_id.puts "quit"
end

task :msf_install => '/tmp/msf-test/msfconsole' do
  # Handled by the 'test/msf-test/msfconsole' task.
end

task :msf_update => '/tmp/msf-test/msfconsole' do
  sh "cd /tmp/msf-test;git pull"
end

file '/tmp/msf-test/msfconsole' do
  puts "Installing MSF"
  sh "cd test;git clone https://github.com/rapid7/metasploit-framework.git /tmp/msf-test"
end


################################
# Create Mac DMG File

task :dmg do
  puts "\nCreating Working Directory\n";
  sh "mkdir dmg";
  sh "mkdir dmg/BeEF";
  sh "rsync * dmg/BeEF --exclude=dmg -r";
  sh "ln -s /Applications dmg/";
  puts "\nCreating DMG File\n"
  sh "hdiutil create ./BeEF.dmg -srcfolder dmg -volname BeEF -ov";
  puts "\nCleaning Up\n"
  sh "rm -r dmg";
  puts "\nBeEF.dmg created\n"
end


################################
# ActiveRecord
namespace :db do
  task :environment do
    require_relative "beef"
  end
end
