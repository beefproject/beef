#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'spec_helper'
require 'capybara/rspec'
require_relative '../support/beef_test'

RSpec.describe BeefTest, run_on_long_tests: true  do

    before(:each) do
        @pid = start_beef_server_and_wait
    end

    after(:each) do
        stop_beef_server(@pid)
    end

    describe '.login' do
        it 'logs in successfully' do
            expect(port_available?) # Check if the tcp port is open
            session = BeefTest.login()
            expect(session).not_to be_nil
            expect(session.has_content?('Hooked Browsers', wait: 10))
        end
    end

    describe '.logout' do
        before(:each) do
            expect(port_available?) # # Check if the tcp port is open
            @session = BeefTest.login() # Ensure login before each '.logout' test
            expect(@session.has_content?('Hooked Browsers', wait: 10))
        end

        it 'logs out successfully' do
            expect(port_available?) # # Check if the tcp port is open
            expect(@session.has_content?('Hooked Browsers', wait: 10))
            
            # Log out of the session
            @sessoin = BeefTest.logout(@session)
            expect(@session.has_no_content?('Hooked Browsers', wait: 10))
            expect(@session.has_content?('Authentication', wait: 10))
        @session.reset_session!
        end
    end

    describe '.save_screenshot' do
        it 'saves a screenshot' do
            session = Capybara::Session.new(:selenium_headless) if session.nil?
            
            # Ensure the new directory does not exist
            outputDir = '/tmp'
            directory = "#{outputDir}/#{SecureRandom.hex}/"
            expect(File.directory?(directory)).to be false

            # Save the screenshot
            BeefTest.save_screenshot(session, directory)

            # Ensure the screenshot was saved
            expect(File.directory?(directory)).to be true
            screenshot_files = Dir.glob("#{directory}/*.png")
            expect(screenshot_files.empty?).to be false

            # Ensure the screenshot file is not empty and clean up
            screenshot_files.each do |file|
                expect(File.size(file)).to be > 0
                File.delete(file)
            end
            expect(Dir.glob("#{directory}/*.png").empty?).to be true     
            
            # Remove the directory
            Dir.delete(directory)
            expect(File.directory?(directory)).to be false
        end
    end

    let(:session) { Capybara::Session.new(:selenium_headless) }
    let(:victim) { Capybara::Session.new(:selenium_headless) }

    describe '.new_attacker' do
        it 'creates a new attacker session' do
            # # Test setup
            expect(session).not_to be_nil

            result = BeefTest.new_attacker(session)
            
            # Test assertions
            expect(result).to eq(session)
            expect(session.has_no_content?('Authentication', wait: 10))
            expect(session.has_content?('Hooked Browsers', wait: 10))
            session.reset_session!
        end
    end

    describe '.new_victim' do
        it 'creates a new victim session' do
            # Test setup
            allow(victim).to receive(:visit)
            expect(victim).not_to be_nil

            # Test execution
            result = BeefTest.new_victim(victim)

            # Test assertions
            expect(victim).to have_received(:visit).with(VICTIM_URL)
            expect(result).to eq(victim)
            victim.reset_session!
        end
    end
end
