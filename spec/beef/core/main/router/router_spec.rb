#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Core::Router::Router do
  let(:config) { BeEF::Core::Configuration.instance }

  # Create a test instance that we can call private methods on
  let(:router_instance) do
    instance = described_class.allocate
    instance.instance_variable_set(:@config, config)
    instance
  end

  describe '#response_headers' do
    it 'returns default headers when web server imitation is disabled' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(false)
      headers = router_instance.send(:response_headers)
      expect(headers['Server']).to eq('')
      expect(headers['Content-Type']).to eq('text/html')
    end

    it 'returns Apache headers when type is apache' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(true)
      allow(config).to receive(:get).with('beef.http.web_server_imitation.type').and_return('apache')
      headers = router_instance.send(:response_headers)
      expect(headers['Server']).to eq('Apache/2.2.3 (CentOS)')
      expect(headers['Content-Type']).to eq('text/html; charset=UTF-8')
    end

    it 'returns IIS headers when type is iis' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(true)
      allow(config).to receive(:get).with('beef.http.web_server_imitation.type').and_return('iis')
      headers = router_instance.send(:response_headers)
      expect(headers['Server']).to eq('Microsoft-IIS/6.0')
      expect(headers['X-Powered-By']).to eq('ASP.NET')
      expect(headers['Content-Type']).to eq('text/html; charset=UTF-8')
    end

    it 'returns nginx headers when type is nginx' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(true)
      allow(config).to receive(:get).with('beef.http.web_server_imitation.type').and_return('nginx')
      headers = router_instance.send(:response_headers)
      expect(headers['Server']).to eq('nginx')
      expect(headers['Content-Type']).to eq('text/html')
    end

    it 'returns default headers for invalid type' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(true)
      allow(config).to receive(:get).with('beef.http.web_server_imitation.type').and_return('invalid')
      headers = router_instance.send(:response_headers)
      expect(headers['Server']).to eq('')
      expect(headers['Content-Type']).to eq('text/html')
    end
  end

  describe '#index_page' do
    it 'returns empty string when web server imitation is disabled' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(false)
      result = router_instance.send(:index_page)
      expect(result).to eq('')
    end

    it 'returns Apache index page when enabled and type is apache' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(true)
      allow(config).to receive(:get).with('beef.http.web_server_imitation.type').and_return('apache')
      allow(config).to receive(:get).with('beef.extension.admin_ui.base_path').and_return('/ui')
      allow(config).to receive(:get).with('beef.http.web_server_imitation.hook_root').and_return(false)
      result = router_instance.send(:index_page)
      expect(result).to include('Apache HTTP Server Test Page')
      expect(result).to include('powered by CentOS')
    end

    it 'returns IIS index page when enabled and type is iis' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(true)
      allow(config).to receive(:get).with('beef.http.web_server_imitation.type').and_return('iis')
      allow(config).to receive(:get).with('beef.extension.admin_ui.base_path').and_return('/ui')
      allow(config).to receive(:get).with('beef.http.web_server_imitation.hook_root').and_return(false)
      result = router_instance.send(:index_page)
      expect(result).to include('Under Construction')
    end

    it 'returns nginx index page when enabled and type is nginx' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(true)
      allow(config).to receive(:get).with('beef.http.web_server_imitation.type').and_return('nginx')
      allow(config).to receive(:get).with('beef.http.web_server_imitation.hook_root').and_return(false)
      # nginx doesn't use base_path, but the method might check it
      allow(config).to receive(:get).with('beef.extension.admin_ui.base_path').and_return('/ui')
      result = router_instance.send(:index_page)
      expect(result).to include('Welcome to nginx!')
    end

    it 'includes hook script when hook_root is enabled' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(true)
      allow(config).to receive(:get).with('beef.http.web_server_imitation.type').and_return('apache')
      allow(config).to receive(:get).with('beef.extension.admin_ui.base_path').and_return('/ui')
      allow(config).to receive(:get).with('beef.http.web_server_imitation.hook_root').and_return(true)
      allow(config).to receive(:get).with('beef.http.hook_file').and_return('/hook.js')
      result = router_instance.send(:index_page)
      expect(result).to include("<script src='/hook.js'></script>")
    end
  end

  describe '#error_page_404' do
    it 'returns simple message when web server imitation is disabled' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(false)
      result = router_instance.send(:error_page_404)
      expect(result).to eq('Not Found.')
    end

    it 'returns Apache 404 page when enabled and type is apache' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(true)
      allow(config).to receive(:get).with('beef.http.web_server_imitation.type').and_return('apache')
      allow(config).to receive(:get).with('beef.http.web_server_imitation.hook_404').and_return(false)
      result = router_instance.send(:error_page_404)
      expect(result).to include('404 Not Found')
      expect(result).to include('Apache/2.2.3 (CentOS)')
    end

    it 'returns IIS 404 page when enabled and type is iis' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(true)
      allow(config).to receive(:get).with('beef.http.web_server_imitation.type').and_return('iis')
      allow(config).to receive(:get).with('beef.http.web_server_imitation.hook_404').and_return(false)
      result = router_instance.send(:error_page_404)
      expect(result).to include('The page cannot be found')
    end

    it 'returns nginx 404 page when enabled and type is nginx' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(true)
      allow(config).to receive(:get).with('beef.http.web_server_imitation.type').and_return('nginx')
      allow(config).to receive(:get).with('beef.http.web_server_imitation.hook_404').and_return(false)
      result = router_instance.send(:error_page_404)
      expect(result).to include('404 Not Found')
      expect(result).to include('nginx')
    end

    it 'includes hook script when hook_404 is enabled' do
      allow(config).to receive(:get).with('beef.http.web_server_imitation.enable').and_return(true)
      allow(config).to receive(:get).with('beef.http.web_server_imitation.type').and_return('apache')
      allow(config).to receive(:get).with('beef.http.web_server_imitation.hook_404').and_return(true)
      allow(config).to receive(:get).with('beef.http.hook_file').and_return('/hook.js')
      result = router_instance.send(:error_page_404)
      expect(result).to include("<script src='/hook.js'></script>")
    end
  end

end
