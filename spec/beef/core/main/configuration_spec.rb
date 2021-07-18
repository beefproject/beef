RSpec.describe 'BeEF Configuration' do
  before(:all) do
    @config_instance = BeEF::Core::Configuration.instance
  end
  
  context 'http local host configuration values' do
    it 'should set the local host value to 0.0.0.0' do
      @config_instance.set('beef.http.host', '0.0.0.0')
      expect(@config_instance.get('beef.http.host')).to eq('0.0.0.0')
    end

    it 'should get the local host value' do
      @config_instance.set('beef.http.host', '0.0.0.0')
      expect(@config_instance.local_host).to eq('0.0.0.0')
    end

    it 'should get the default host value' do
      @config_instance.set('beef.http.host', nil)
      expect(@config_instance.get('beef.http.host')).to eq(nil)
      expect(@config_instance.local_host).to eq('0.0.0.0')
    end
  end

  context 'http local port configuration values' do
    it 'should set the local port value to 3000' do
      @config_instance.set('beef.http.port', '3000')
      expect(@config_instance.get('beef.http.port')).to eq('3000')
    end

    it 'should get the local port value' do
      @config_instance.set('beef.http.port', '3000')
      expect(@config_instance.local_port).to eq('3000')
    end

    it 'should get the default port value' do
      @config_instance.set('beef.http.port', nil)
      expect(@config_instance.get('beef.http.port')).to eq(nil)
      expect(@config_instance.local_port).to eq('3000')
    end
  end

  context 'beef https enabled configuration values' do
    it 'should set the https enabled config value' do
      @config_instance.set('beef.https.enabled', true)
      expect(@config_instance.get('beef.https.enabled')).to eq(true)
    end

    it 'should get https enabled value set to true' do
      @config_instance.set('beef.https.enabled', true)
      expect(@config_instance.local_https_enabled).to eq(true)
    end

    it 'should get https enabled value set to false' do
      @config_instance.set('beef.https.enabled', false)
      expect(@config_instance.local_https_enabled).to eq(false)
    end

    it 'should get the default https enabled value' do
      @config_instance.set('beef.https.enabled', nil)
      expect(@config_instance.get('beef.https.enabled')).to eq(nil)
      expect(@config_instance.local_https_enabled).to eq(false)
    end
  end
end
