#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'spec_helper'

RSpec.describe 'BeEF::Settings' do
  describe '.extension_exists?' do
    it 'returns true for existing extensions and false for non-existing ones' do
      # Test with a known extension if available
      expect(BeEF::Settings.extension_exists?('AdminUI')).to be(true) if BeEF::Extension.const_defined?('AdminUI')

      expect(BeEF::Settings.extension_exists?('NonExistentExtension')).to be(false)
    end

    it 'raises errors for invalid inputs' do
      expect { BeEF::Settings.extension_exists?(nil) }.to raise_error(TypeError)
      expect { BeEF::Settings.extension_exists?('') }.to raise_error(NameError)
    end
  end

  describe '.console?' do
    it 'delegates to extension_exists? with Console' do
      allow(BeEF::Settings).to receive(:extension_exists?).with('Console').and_return(true)
      expect(BeEF::Settings.console?).to be(true)

      allow(BeEF::Settings).to receive(:extension_exists?).with('Console').and_return(false)
      expect(BeEF::Settings.console?).to be(false)
    end
  end
end
