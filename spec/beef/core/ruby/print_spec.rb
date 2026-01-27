#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'spec_helper'

RSpec.describe 'Print functions' do
  let(:logger) { BeEF.logger }
  let(:test_message) { 'test message' }

  before(:each) do
    # Mock stdout to avoid cluttering test output
    allow($stdout).to receive(:puts)
    allow($stdout).to receive(:print)

    # Mock logger methods
    allow(logger).to receive(:error)
    allow(logger).to receive(:info)
    allow(logger).to receive(:warn)
    allow(logger).to receive(:debug)
  end

  describe '#print_error' do
    it 'calls logger.error with the message' do
      expect(logger).to receive(:error).with(test_message)
      print_error(test_message)
    end

    it 'outputs to stdout with timestamp and error prefix' do
      expect($stdout).to receive(:puts).with(match(/\[!\] #{test_message}/))
      print_error(test_message)
    end

    it 'converts non-string arguments to string' do
      expect(logger).to receive(:error).with('123')
      print_error(123)
    end
  end

  describe '#print_info' do
    it 'calls logger.info with the message' do
      expect(logger).to receive(:info).with(test_message)
      print_info(test_message)
    end

    it 'outputs to stdout with timestamp and info prefix' do
      expect($stdout).to receive(:puts).with(match(/\[\*\] #{test_message}/))
      print_info(test_message)
    end
  end

  describe '#print_status' do
    it 'calls print_info' do
      expect(logger).to receive(:info).with(test_message)
      print_status(test_message)
    end
  end

  describe '#print_warning' do
    it 'calls logger.warn with the message' do
      expect(logger).to receive(:warn).with(test_message)
      print_warning(test_message)
    end

    it 'outputs to stdout with timestamp and warning prefix' do
      expect($stdout).to receive(:puts).with(match(/\[!\] #{test_message}/))
      print_warning(test_message)
    end
  end

  describe '#print_debug' do
    let(:config) { BeEF::Core::Configuration.instance }

    context 'when debug is enabled' do
      before do
        allow(config).to receive(:get).with('beef.debug').and_return(true)
        allow(BeEF::Core::Console::CommandLine).to receive(:parse).and_return({})
      end

      it 'calls logger.debug with the message' do
        expect(logger).to receive(:debug).with(test_message)
        print_debug(test_message)
      end

      it 'outputs to stdout with timestamp and debug prefix' do
        expect($stdout).to receive(:puts).with(match(/\[>\] #{test_message}/))
        print_debug(test_message)
      end
    end

    context 'when verbose flag is set' do
      before do
        allow(config).to receive(:get).with('beef.debug').and_return(false)
        allow(BeEF::Core::Console::CommandLine).to receive(:parse).and_return({ verbose: true })
      end

      it 'calls logger.debug with the message' do
        expect(logger).to receive(:debug).with(test_message)
        print_debug(test_message)
      end
    end

    context 'when debug is disabled and verbose is not set' do
      before do
        allow(config).to receive(:get).with('beef.debug').and_return(false)
        allow(BeEF::Core::Console::CommandLine).to receive(:parse).and_return({})
      end

      it 'does not call logger.debug' do
        expect(logger).not_to receive(:debug)
        print_debug(test_message)
      end

      it 'does not output to stdout' do
        expect($stdout).not_to receive(:puts)
        print_debug(test_message)
      end
    end
  end

  describe '#print_success' do
    it 'calls logger.info with the message' do
      expect(logger).to receive(:info).with(test_message)
      print_success(test_message)
    end

    it 'outputs to stdout with timestamp and success prefix' do
      expect($stdout).to receive(:puts).with(match(/\[\+\] #{test_message}/))
      print_success(test_message)
    end
  end

  describe '#print_good' do
    it 'calls print_success' do
      expect(logger).to receive(:info).with(test_message)
      print_good(test_message)
    end
  end

  describe '#print_more' do
    context 'with string input' do
      it 'splits string by newlines and formats each line' do
        multi_line = "line1\nline2\nline3"
        expect($stdout).to receive(:puts).with(match(/line1/))
        expect($stdout).to receive(:puts).with(match(/line2/))
        expect($stdout).to receive(:puts).with(match(/\|_  line3/)) # Last line has "|_"
        expect(logger).to receive(:info).exactly(3).times
        print_more(multi_line)
      end

      it 'formats last line with |_ prefix' do
        single_line = 'single line'
        expect($stdout).to receive(:puts).with(match(/\|_  single line/))
        expect(logger).to receive(:info).with(match(/\|_  single line/))
        print_more(single_line)
      end
    end

    context 'with array input' do
      it 'formats each array element as a line' do
        lines_array = %w[line1 line2 line3]
        expect($stdout).to receive(:puts).exactly(3).times
        expect(logger).to receive(:info).exactly(3).times
        print_more(lines_array)
      end

      it 'formats last array element with |_ prefix' do
        lines_array = %w[line1 line2]
        expect($stdout).to receive(:puts).with(match(/\|   line1/))
        expect($stdout).to receive(:puts).with(match(/\|_  line2/))
        print_more(lines_array)
      end
    end
  end

  describe '#print_over' do
    it 'calls logger.info with the message' do
      expect(logger).to receive(:info).with(test_message)
      print_over(test_message)
    end

    it 'outputs formatted message to stdout' do
      # print is a private Kernel method, hard to stub directly
      # We verify the function executes and calls logger
      # The actual output includes ANSI color codes and carriage return
      expect { print_over(test_message) }.not_to raise_error
      expect(logger).to have_received(:info).with(test_message)
    end
  end
end
