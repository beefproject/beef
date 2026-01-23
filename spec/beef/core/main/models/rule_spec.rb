RSpec.describe BeEF::Core::Models::Rule do
  describe 'associations' do
    it 'has_many executions' do
      expect(described_class.reflect_on_association(:executions)).not_to be_nil
      expect(described_class.reflect_on_association(:executions).macro).to eq(:has_many)
    end
  end

  describe '.create' do
    it 'creates a rule with required attributes' do
      rule = described_class.create!(
        name: 'test_rule',
        author: 'test_author',
        browser: 'FF',
        browser_version: '1.0',
        os: 'Windows',
        os_version: '10',
        modules: [].to_json,
        execution_order: '1',
        execution_delay: '0',
        chain_mode: 'sequential'
      )

      expect(rule).to be_persisted
      expect(rule.name).to eq('test_rule')
      expect(rule.chain_mode).to eq('sequential')
    end

    it 'can have multiple executions' do
      rule = described_class.create!(
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

      execution1 = BeEF::Core::Models::Execution.create!(rule_id: rule.id)
      execution2 = BeEF::Core::Models::Execution.create!(rule_id: rule.id)

      expect(rule.executions.count).to eq(2)
      expect(rule.executions).to include(execution1, execution2)
    end
  end
end
