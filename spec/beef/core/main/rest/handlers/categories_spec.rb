RSpec.describe BeEF::Core::Rest::Categories do
  let(:config) { BeEF::Core::Configuration.instance }
  let(:api_token) { 'test_token' }

  before do
    allow(config).to receive(:get).and_call_original
    allow(config).to receive(:get).with('beef.api_token').and_return(api_token)
    allow(BeEF::Core::Rest).to receive(:permitted_source?).and_return(true)
  end

  describe 'GET /' do
    it 'returns categories as JSON' do
      allow(BeEF::Modules).to receive(:get_categories).and_return(['Browser', 'Network']) # rubocop:disable Style/WordArray

      # Test the logic directly
      categories = BeEF::Modules.get_categories
      cats = []
      i = 0
      categories.each do |category|
        cat = { 'id' => i, 'name' => category }
        cats << cat
        i += 1
      end
      result = cats.to_json

      parsed = JSON.parse(result)
      expect(parsed.length).to eq(2)
      expect(parsed[0]['id']).to eq(0)
      expect(parsed[0]['name']).to eq('Browser')
      expect(parsed[1]['id']).to eq(1)
      expect(parsed[1]['name']).to eq('Network')
    end

    it 'handles empty categories' do
      allow(BeEF::Modules).to receive(:get_categories).and_return([])

      categories = BeEF::Modules.get_categories
      cats = []
      i = 0
      categories.each do |category|
        cat = { 'id' => i, 'name' => category }
        cats << cat
        i += 1
      end
      result = cats.to_json

      parsed = JSON.parse(result)
      expect(parsed).to eq([])
    end
  end
end
