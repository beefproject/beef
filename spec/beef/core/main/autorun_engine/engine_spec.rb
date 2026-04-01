#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Example: unit specs for AutorunEngine::Engine using mocks instead of a real server/DB.
#

require 'spec_helper'

RSpec.describe BeEF::Core::AutorunEngine::Engine do
  let(:engine) { described_class.instance }
  let(:config) { BeEF::Core::Configuration.instance }

  before do
    allow(engine).to receive(:print_debug)
    allow(engine).to receive(:print_info)
    allow(engine).to receive(:print_more)
    allow(engine).to receive(:print_error)
  end

  # Fake rule object (could be a double or a persisted Rule with minimal attributes)
  def rule_with(browser: 'ALL', browser_version: 'ALL', os: 'ALL', os_version: 'ALL')
    double(
      'Rule',
      id: 1,
      browser: browser,
      browser_version: browser_version,
      os: os,
      os_version: os_version
    )
  end

  describe '#zombie_matches_rule?' do
    it 'returns false when rule is nil' do
      expect(engine.zombie_matches_rule?('FF', '41', 'Windows', '7', nil)).to be false
    end

    it 'returns true when rule is ALL for browser and OS' do
      rule = rule_with(browser: 'ALL', browser_version: 'ALL', os: 'ALL', os_version: 'ALL')
      allow(engine).to receive(:zombie_browser_matches_rule?).with('FF', '41', rule).and_return(true)
      allow(engine).to receive(:zombie_os_matches_rule?).with('Windows', '7', rule).and_return(true)
      expect(engine.zombie_matches_rule?('FF', '41', 'Windows', '7', rule)).to be true
    end

    it 'returns false when browser does not match' do
      rule = rule_with(browser: 'FF', browser_version: '>= 41', os: 'ALL', os_version: 'ALL')
      allow(engine).to receive(:zombie_browser_matches_rule?).with('FF', '41', rule).and_return(false)
      expect(engine.zombie_matches_rule?('FF', '41', 'Windows', '7', rule)).to be false
    end

    it 'returns false when OS does not match' do
      rule = rule_with(browser: 'ALL', browser_version: 'ALL', os: 'Windows', os_version: '7')
      allow(engine).to receive(:zombie_browser_matches_rule?).with('FF', '41', rule).and_return(true)
      allow(engine).to receive(:zombie_os_matches_rule?).with('Windows', '7', rule).and_return(false)
      expect(engine.zombie_matches_rule?('FF', '41', 'Windows', '7', rule)).to be false
    end
  end

  describe '#zombie_os_matches_rule?' do
    it 'returns false when rule is nil' do
      expect(engine.zombie_os_matches_rule?('Windows', '7', nil)).to be false
    end

    it 'returns true when rule os is ALL' do
      rule = double('Rule', os: 'ALL', os_version: 'ALL')
      expect(engine.zombie_os_matches_rule?('Windows', '7', rule)).to be true
    end

    it 'returns false when hook os does not match rule os' do
      rule = double('Rule', os: 'Linux', os_version: 'ALL')
      expect(engine.zombie_os_matches_rule?('Windows', '7', rule)).to be false
    end

    it 'returns true when rule os matches and os_version is ALL' do
      rule = double('Rule', os: 'Windows', os_version: 'ALL')
      expect(engine.zombie_os_matches_rule?('Windows', '7', rule)).to be true
    end
  end

  describe '#zombie_browser_matches_rule?' do
    it 'returns false when rule is nil' do
      expect(engine.zombie_browser_matches_rule?('FF', '41', nil)).to be false
    end

    it 'returns true when rule browser is ALL and version is ALL' do
      rule = double('Rule', browser: 'ALL', browser_version: 'ALL')
      expect(engine.zombie_browser_matches_rule?('FF', '41', rule)).to be true
    end

    it 'returns true when rule browser matches and version is ALL' do
      rule = double('Rule', browser: 'FF', browser_version: 'ALL')
      expect(engine.zombie_browser_matches_rule?('FF', '41', rule)).to be true
    end

    it 'returns false when rule browser does not match' do
      rule = double('Rule', browser: 'IE', browser_version: 'ALL')
      expect(engine.zombie_browser_matches_rule?('FF', '41', rule)).to be false
    end
  end

  describe '#find_matching_rules_for_zombie' do
    it 'returns nil when no rules exist' do
      allow(BeEF::Core::Models::Rule).to receive(:all).and_return([])
      expect(engine.find_matching_rules_for_zombie('FF', '41', 'Windows', '7')).to be_nil
    end

    it 'returns matching rule ids when rules match zombie' do
      rule1 = double('Rule', id: 1, name: 'Rule1', browser: 'ALL', browser_version: 'ALL', os: 'ALL', os_version: 'ALL')
      rule2 = double('Rule', id: 2, name: 'Rule2', browser: 'IE', browser_version: 'ALL', os: 'ALL', os_version: 'ALL')
      allow(BeEF::Core::Models::Rule).to receive(:all).and_return([rule1, rule2])
      allow(engine).to receive(:zombie_matches_rule?).with('FF', '41', 'Windows', '7', rule1).and_return(true)
      allow(engine).to receive(:zombie_matches_rule?).with('FF', '41', 'Windows', '7', rule2).and_return(false)
      expect(engine.find_matching_rules_for_zombie('FF', '41', 'Windows', '7')).to eq([1])
    end
  end

  describe '#compare_versions' do
    it 'returns true when cond is ALL' do
      expect(engine.send(:compare_versions, '7', 'ALL', '8')).to be true
    end

    it 'returns true when cond is == and versions equal' do
      expect(engine.send(:compare_versions, '41', '==', '41')).to be true
    end

    it 'returns false when cond is == and versions differ' do
      expect(engine.send(:compare_versions, '41', '==', '42')).to be false
    end

    it 'returns true when cond is <= and ver_a <= ver_b' do
      expect(engine.send(:compare_versions, '41', '<=', '42')).to be true
      expect(engine.send(:compare_versions, '41', '<=', '41')).to be true
    end

    it 'returns false when cond is <= and ver_a > ver_b' do
      expect(engine.send(:compare_versions, '42', '<=', '41')).to be false
    end

    it 'returns true when cond is < and ver_a < ver_b' do
      expect(engine.send(:compare_versions, '41', '<', '42')).to be true
    end

    it 'returns false when cond is < and ver_a >= ver_b' do
      expect(engine.send(:compare_versions, '42', '<', '41')).to be false
      expect(engine.send(:compare_versions, '41', '<', '41')).to be false
    end

    it 'returns true when cond is >= and ver_a >= ver_b' do
      expect(engine.send(:compare_versions, '42', '>=', '41')).to be true
      expect(engine.send(:compare_versions, '41', '>=', '41')).to be true
    end

    it 'returns true when cond is > and ver_a > ver_b' do
      expect(engine.send(:compare_versions, '42', '>', '41')).to be true
    end

    it 'returns false when cond is > and ver_a <= ver_b' do
      expect(engine.send(:compare_versions, '41', '>', '42')).to be false
      expect(engine.send(:compare_versions, '41', '>', '41')).to be false
    end

    it 'returns false for unknown cond' do
      expect(engine.send(:compare_versions, '41', '!=', '42')).to be false
    end
  end

  describe '#clean_command_body' do
    it 'extracts body range and replaces single-quoted mod_input when replace_input is true' do
      body = "beef.execute(function(){\n  alert('<<mod_input>>');\n});\n"
      result = engine.send(:clean_command_body, body, true)
      expect(result).to include('alert(mod_input)')
      expect(result).to include('beef.execute(function(){')
    end

    it 'returns cleaned body without mod_input replacement when replace_input is false' do
      body = "beef.execute(function(){\n  doSomething('<<mod_input>>');\n});\n"
      result = engine.send(:clean_command_body, body, false)
      expect(result).to include('<<mod_input>>')
    end

    it 'replaces double-quoted <<mod_input>> with mod_input when replace_input is true' do
      body = "beef.execute(function(){\n  x(\"<<mod_input>>\");\n});\n"
      result = engine.send(:clean_command_body, body, true)
      expect(result).to include('mod_input')
      expect(result).not_to include('"<<mod_input>>"')
    end

    it 'replaces single-quoted <<mod_input>> with mod_input when replace_input is true' do
      body = "beef.execute(function(){\n  x('<<mod_input>>');\n});\n"
      result = engine.send(:clean_command_body, body, true)
      expect(result).to include('mod_input')
    end
  end

  describe '#prepare_sequential_wrapper' do
    it 'builds wrapper with mod bodies and setTimeout calls in order' do
      mods = [
        { mod_name: 'mod_a', mod_body: 'var mod_a_mod_output = 1;' },
        { mod_name: 'mod_b', mod_body: 'var mod_b_mod_output = 2;' }
      ]
      order = [0, 1]
      delay = [0, 500]
      token = 't1'
      result = engine.send(:prepare_sequential_wrapper, mods, order, delay, token)
      expect(result).to include('mod_a_t1')
      expect(result).to include('mod_b_t1')
      expect(result).to include('setTimeout(function(){mod_a_t1();}, 0)')
      expect(result).to include('setTimeout(function(){mod_b_t1();}, 500)')
      expect(result).to include('mod_a_t1_mod_output')
      expect(result).to include('mod_b_t1_mod_output')
    end

    it 'handles single module' do
      mods = [{ mod_name: 'single', mod_body: 'x();' }]
      order = [0]
      delay = [0]
      result = engine.send(:prepare_sequential_wrapper, mods, order, delay, 'tk')
      expect(result).to include('single_tk')
      expect(result).to include('setTimeout(function(){single_tk();}, 0)')
    end
  end

  describe '#prepare_nested_forward_wrapper' do
    it 'builds wrapper for single module' do
      mods = [{ mod_name: 'only', mod_body: 'only();' }]
      code = ['null']
      conditions = [true]
      order = [0]
      token = 'nf1'
      result = engine.send(:prepare_nested_forward_wrapper, mods, code, conditions, order, token)
      expect(result).to include('only_nf1')
      expect(result).to include('only_nf1_f')
      expect(result).to include('only_nf1_mod_output')
    end
  end

  describe '#find_and_run_all_matching_rules_for_zombie' do
    it 'returns without calling run_rules when hb_id is nil' do
      expect(engine).not_to receive(:run_rules_on_zombie)
      engine.find_and_run_all_matching_rules_for_zombie(nil)
    end

    it 'returns without calling run_rules when find_matching_rules returns nil' do
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'browser.name').and_return('FF')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'browser.version').and_return('41')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'host.os.name').and_return('Windows')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'host.os.version').and_return('7')
      allow(engine).to receive(:find_matching_rules_for_zombie).with('FF', '41', 'Windows', '7').and_return(nil)
      expect(engine).not_to receive(:run_rules_on_zombie)
      engine.find_and_run_all_matching_rules_for_zombie(1)
    end

    it 'returns without calling run_rules when find_matching_rules returns empty' do
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'browser.name').and_return('FF')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'browser.version').and_return('41')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'host.os.name').and_return('Windows')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'host.os.version').and_return('7')
      allow(engine).to receive(:find_matching_rules_for_zombie).with('FF', '41', 'Windows', '7').and_return([])
      expect(engine).not_to receive(:run_rules_on_zombie)
      engine.find_and_run_all_matching_rules_for_zombie(1)
    end

    it 'calls run_rules_on_zombie with matching rule ids when rules match' do
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'browser.name').and_return('FF')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'browser.version').and_return('41')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'host.os.name').and_return('Windows')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'host.os.version').and_return('7')
      allow(engine).to receive(:find_matching_rules_for_zombie).with('FF', '41', 'Windows', '7').and_return([1, 2])
      expect(engine).to receive(:run_rules_on_zombie).with([1, 2], 1)
      engine.find_and_run_all_matching_rules_for_zombie(1)
    end
  end

  describe '#run_matching_rules_on_zombie' do
    it 'returns when rule_ids is nil' do
      expect(engine).not_to receive(:run_rules_on_zombie)
      engine.run_matching_rules_on_zombie(nil, 1)
    end

    it 'returns when hb_id is nil' do
      expect(engine).not_to receive(:run_rules_on_zombie)
      engine.run_matching_rules_on_zombie([1], nil)
    end

    it 'returns without calling run_rules when find_matching_rules returns nil' do
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'browser.name').and_return('FF')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'browser.version').and_return('41')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'host.os.name').and_return('Windows')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'host.os.version').and_return('7')
      allow(engine).to receive(:find_matching_rules_for_zombie).with('FF', '41', 'Windows', '7').and_return(nil)
      expect(engine).not_to receive(:run_rules_on_zombie)
      engine.run_matching_rules_on_zombie([1], 1)
    end

    it 'calls run_rules_on_zombie with intersection of rule_ids and matching rules' do
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'browser.name').and_return('FF')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'browser.version').and_return('41')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'host.os.name').and_return('Windows')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'host.os.version').and_return('7')
      allow(engine).to receive(:find_matching_rules_for_zombie).with('FF', '41', 'Windows', '7').and_return([1, 2])
      expect(engine).to receive(:run_rules_on_zombie).with([1], 1)
      engine.run_matching_rules_on_zombie([1], 1)
    end

    it 'does not call run_rules_on_zombie when no rule_ids overlap matching rules' do
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'browser.name').and_return('FF')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'browser.version').and_return('41')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'host.os.name').and_return('Windows')
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).with(1, 'host.os.version').and_return('7')
      allow(engine).to receive(:find_matching_rules_for_zombie).with('FF', '41', 'Windows', '7').and_return([1, 2])
      expect(engine).not_to receive(:run_rules_on_zombie)
      engine.run_matching_rules_on_zombie([99], 1)
    end
  end

  describe '#run_rules_on_zombie' do
    it 'returns when rule_ids is nil' do
      expect(BeEF::HBManager).not_to receive(:get_by_id)
      engine.run_rules_on_zombie(nil, 1)
    end

    it 'returns when hb_id is nil' do
      expect(BeEF::HBManager).not_to receive(:get_by_id)
      engine.run_rules_on_zombie([1], nil)
    end

    it 'normalizes single Integer rule_id to array and processes rule' do
      hb = double('HookedBrowser', session: 'sess1')
      allow(BeEF::HBManager).to receive(:get_by_id).with(1).and_return(hb)
      rule = double(
        'Rule',
        modules: '[]',
        execution_order: '[]',
        execution_delay: '[]',
        chain_mode: 'invalid'
      )
      allow(BeEF::Core::Models::Rule).to receive(:find).with(1).and_return(rule)
      engine.run_rules_on_zombie(1, 1)
      expect(BeEF::Core::Models::Rule).to have_received(:find).with(1)
      expect(engine).to have_received(:print_error).with(/Invalid chain mode 'invalid'/)
    end

    it 'prints error and returns when rule has invalid chain_mode' do
      hb = double('HookedBrowser', session: 'sess1')
      allow(BeEF::HBManager).to receive(:get_by_id).with(1).and_return(hb)
      rule = double(
        'Rule',
        modules: '[]',
        execution_order: '[]',
        execution_delay: '[]',
        chain_mode: 'invalid'
      )
      allow(BeEF::Core::Models::Rule).to receive(:find).with(1).and_return(rule)
      engine.run_rules_on_zombie([1], 1)
      expect(engine).to have_received(:print_error).with(/Invalid chain mode 'invalid'/)
    end
  end
end
