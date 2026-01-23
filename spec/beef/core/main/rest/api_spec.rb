RSpec.describe BeEF::Core::Rest do
  describe '.permitted_source?' do
    it 'returns false for invalid IP' do
      expect(BeEF::Core::Rest.permitted_source?('invalid')).to be false
    end

    it 'returns false when permitted_ui_subnet is nil' do
      allow(BeEF::Core::Configuration.instance).to receive(:get).with('beef.restrictions.permitted_ui_subnet').and_return(nil)
      expect(BeEF::Core::Rest.permitted_source?('127.0.0.1')).to be false
    end

    it 'returns false when permitted_ui_subnet is empty' do
      allow(BeEF::Core::Configuration.instance).to receive(:get).with('beef.restrictions.permitted_ui_subnet').and_return([])
      expect(BeEF::Core::Rest.permitted_source?('127.0.0.1')).to be false
    end

    it 'returns true when IP is in permitted subnet' do
      allow(BeEF::Core::Configuration.instance).to receive(:get).with('beef.restrictions.permitted_ui_subnet').and_return(['127.0.0.0/8'])
      expect(BeEF::Core::Rest.permitted_source?('127.0.0.1')).to be true
    end

    it 'returns false when IP is not in permitted subnet' do
      allow(BeEF::Core::Configuration.instance).to receive(:get).with('beef.restrictions.permitted_ui_subnet').and_return(['192.168.0.0/24'])
      expect(BeEF::Core::Rest.permitted_source?('127.0.0.1')).to be false
    end
  end

  describe '.timeout?' do
    let(:config) { BeEF::Core::Configuration.instance }

    it 'returns true when enough time has passed' do
      allow(config).to receive(:get).with('beef.restrictions.api_attempt_delay').and_return(1)
      last_time = Time.now - 2
      time_setter = ->(_time) {}
      expect(BeEF::Core::Rest.timeout?('beef.restrictions.api_attempt_delay', last_time, time_setter)).to be true
    end

    it 'returns false when not enough time has passed' do
      allow(config).to receive(:get).with('beef.restrictions.api_attempt_delay').and_return(5)
      last_time = Time.now - 1
      time_set = nil
      time_setter = ->(time) { time_set = time }
      result = BeEF::Core::Rest.timeout?('beef.restrictions.api_attempt_delay', last_time, time_setter)
      expect(result).to be false
      expect(time_set).not_to be_nil
    end
  end
end
