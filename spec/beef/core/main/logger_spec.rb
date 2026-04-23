#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::Logger do
  let(:logger) { described_class.instance }
  let(:log_double) { instance_double(BeEF::Core::Models::Log, save!: true) }

  before do
    allow(BeEF::Core::Models::Log).to receive(:create).and_return(log_double)
    allow(logger).to receive(:print_debug)
    logger.instance_variable_set(:@notifications, nil)
  end

  describe '#register' do
    it 'creates a log entry with from, event, and hooked_browser_id' do
      result = logger.register('Authentication', 'User logged in', 0)

      expect(result).to be true
      expect(BeEF::Core::Models::Log).to have_received(:create).with(
        hash_including(
          logtype: 'Authentication',
          event: 'User logged in',
          hooked_browser_id: 0
        )
      )
      expect(log_double).to have_received(:save!)
    end

    it 'converts hb to integer' do
      logger.register('From', 'Event', '42')

      expect(BeEF::Core::Models::Log).to have_received(:create).with(
        hash_including(hooked_browser_id: 42)
      )
    end

    it 'defaults hb to 0 when not provided' do
      logger.register('From', 'Event')

      expect(BeEF::Core::Models::Log).to have_received(:create).with(
        hash_including(hooked_browser_id: 0)
      )
    end

    it 'raises TypeError when from is not a String' do
      expect { logger.register(123, 'Event', 0) }.to raise_error(
        TypeError, "'from' is Integer; expected String"
      )
    end

    it 'raises TypeError when event is not a String' do
      expect { logger.register('From', nil, 0) }.to raise_error(
        TypeError, "'event' is NilClass; expected String"
      )
    end

    it 'calls notifications when extension is enabled' do
      notifications_double = double('Notifications')
      logger.instance_variable_set(:@notifications, notifications_double)
      allow(notifications_double).to receive(:new)
      logger.register('Zombie', 'Browser hooked', 7)
      expect(notifications_double).to have_received(:new).with(
        'Zombie',
        'Browser hooked',
        kind_of(Time),
        7
      )
    end
  end
end
