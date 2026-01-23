RSpec.describe BeEF::Core::Models::Execution do
  describe '.create' do
    let(:rule) do
      BeEF::Core::Models::Rule.create!(
        name: 'test_rule',
        author: 'test',
        browser: 'FF',
        browser_version: '1.0',
        os: 'Windows',
        os_version: '10',
        modules: [].to_json,
        execution_order: '1',
        execution_delay: '0',
        chain_mode: 'sequential'
      )
    end

    it 'creates an execution with a rule_id' do
      execution = described_class.create!(rule_id: rule.id)

      expect(execution).to be_persisted
      expect(execution.rule_id).to eq(rule.id)
    end

    it 'can access rule_id' do
      execution = described_class.create!(rule_id: rule.id)

      expect(execution.rule_id).to eq(rule.id)
    end
  end
end
