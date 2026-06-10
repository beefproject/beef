#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'spec_helper'
require 'fileutils'

RSpec.describe 'BeEF Logger' do
  let(:home_dir) { $home_dir } # rubocop:disable Style/GlobalVars
  let(:expected_log_path) { File.join(home_dir, 'beef.log') }

  before(:each) do
    # Reset the logger to ensure clean state
    BeEF.logger = nil
  end

  after(:each) do
    # Clean up any log files created during tests
    FileUtils.rm_f(expected_log_path)
    BeEF.logger = nil
  end

  describe '.logger' do
    it 'returns a Logger instance' do
      expect(BeEF.logger).to be_a(Logger)
    end

    it 'creates logger with correct file path' do
      logger = BeEF.logger
      expect(logger.instance_variable_get(:@logdev).dev.path).to eq(expected_log_path)
    end

    it 'sets the progname to BeEF' do
      logger = BeEF.logger
      expect(logger.progname).to eq('BeEF')
    end

    it 'sets the log level to WARN' do
      logger = BeEF.logger
      expect(logger.level).to eq(Logger::WARN)
    end

    it 'returns the same logger instance on subsequent calls' do
      logger1 = BeEF.logger
      logger2 = BeEF.logger
      expect(logger1).to be(logger2)
    end

    it 'creates the log file when logger is accessed' do
      # Ensure file doesn't exist initially
      FileUtils.rm_f(expected_log_path)

      BeEF.logger

      expect(File.exist?(expected_log_path)).to be(true)
    end
  end

  describe '.logger=' do
    it 'allows setting a custom logger' do
      custom_logger = Logger.new($stdout)
      BeEF.logger = custom_logger

      expect(BeEF.logger).to be(custom_logger)
    end

    it 'uses the custom logger instead of creating a new one' do
      custom_logger = Logger.new($stdout)
      custom_logger.level = Logger::DEBUG
      BeEF.logger = custom_logger

      expect(BeEF.logger.level).to eq(Logger::DEBUG)
      expect(BeEF.logger).to be(custom_logger)
    end

    it 'allows resetting logger to nil' do
      BeEF.logger = nil
      expect(BeEF.instance_variable_get(:@logger)).to be_nil
    end

    it 'creates a new logger after being set to nil' do
      original_logger = BeEF.logger
      BeEF.logger = nil
      new_logger = BeEF.logger

      expect(new_logger).to be_a(Logger)
      expect(new_logger).not_to be(original_logger)
    end
  end

  describe 'logger functionality' do
    it 'can log messages at WARN level' do
      logger = BeEF.logger
      expect { logger.warn('Test warning message') }.not_to raise_error
    end

    it 'can log messages at ERROR level' do
      logger = BeEF.logger
      expect { logger.error('Test error message') }.not_to raise_error
    end

    it 'does not log messages below WARN level by default' do
      logger = BeEF.logger
      # INFO and DEBUG messages should not be logged at WARN level
      expect(logger.info?).to be(false)
      expect(logger.debug?).to be(false)
    end

    it 'logs messages at WARN level and above' do
      logger = BeEF.logger
      expect(logger.warn?).to be(true)
      expect(logger.error?).to be(true)
      expect(logger.fatal?).to be(true)
    end
  end
end
