#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

task :default => ["quick"]

desc "Run quick tests"
task :quick do
  Rake::Task['unit'].invoke                 # run unit tests
end

desc "Run all tests"
task :all do
  Rake::Task['integration'].invoke          # run integration tests
  Rake::Task['unit'].invoke                 # run unit tests
  Rake::Task['msf'].invoke                  # run msf tests
end

desc "Run automated tests (for Jenkins)"
task :automated do
  Rake::Task['xserver_start'].invoke
  Rake::Task['all'].invoke
  Rake::Task['xserver_stop'].invoke
end

desc "Run integration unit tests"
task :integration => ["install"] do
  Rake::Task['beef_start'].invoke
  sh "export DISPLAY=:0; cd test/integration;ruby -W0 ts_integration.rb"
  Rake::Task['beef_stop'].invoke
end

desc "Run integration unit tests"
task :unit => ["install"] do
  sh "cd test/unit;ruby -W0 ts_unit.rb"
end

desc "Run MSF unit tests"
task :msf => ["install", "msf_install"]  do
  Rake::Task['msf_update'].invoke
  Rake::Task['msf_start'].invoke
  sh "cd test/thirdparty/msf/unit/;ruby -W0 ts_metasploit.rb"
  Rake::Task['msf_stop'].invoke
end

task :install do
  sh "export BEEF_TEST=true;bundle install > /dev/null"
end

################################
# X11 set up

@xserver_process_id = nil;

task :xserver_start do
  printf "Starting X11 Server (wait 10 seconds)..."
  @xserver_process_id = IO.popen("/usr/bin/Xvfb :0 -screen 0 1024x768x24 2> /dev/null", "w+")
  delays = [2, 2, 1, 1, 1, 0.5, 0.5 , 0.5, 0.3, 0.2, 0.1, 0.1, 0.1, 0.05, 0.05]
  delays.each do |i| # delay for 10 seconds
    printf '.'
    sleep (i) # increase the . display rate
  end
  puts '.'
end

task :xserver_stop do
  puts "\nShutting down X11 Server...\n"
  sh "ps -ef|grep Xvfb|grep -v grep|awk '{print $2}'|xargs kill"
end

################################
# BeEF environment set up

@beef_process_id = nil;

task :beef_start => 'beef' do
  printf "Starting BeEF (wait 10 seconds)..."
  @beef_process_id = IO.popen("ruby ./beef -x 2> /dev/null", "w+")
  delays = [2, 2, 1, 1, 1, 0.5, 0.5 , 0.5, 0.3, 0.2, 0.1, 0.1, 0.1, 0.05, 0.05]
  delays.each do |i| # delay for 10 seconds
    printf '.'
    sleep (i)
  end
  puts '.'
end

task :beef_stop do
  puts "\nShutting down BeEF...\n"
  sh "ps -ef|grep beef|grep -v grep|awk '{print $2}'|xargs kill"
end

################################
# MSF environment set up

@msf_process_id = nil;

task :msf_start => '/tmp/msf-test/msfconsole' do
  printf "Starting MSF (wait 45 seconds)..."
  @msf_process_id = IO.popen("/tmp/msf-test/msfconsole -r test/thirdparty/msf/unit/BeEF.rc 2> /dev/null", "w+")
  delays = [10, 7, 6, 5, 4, 3, 2, 2, 1, 1, 1, 0.5, 0.5 , 0.5, 0.3, 0.2, 0.1, 0.1, 0.1, 0.05, 0.05]
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

task :msf_update  => '/tmp/msf-test/msfconsole' do
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

