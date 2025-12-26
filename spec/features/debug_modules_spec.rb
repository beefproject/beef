#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'rspec'
require 'rest-client'
require 'spec/support/constants.rb'
require 'spec/support/ui_support.rb'

RSpec.describe 'Debug Modules Integration', run_on_long_tests: true  do
    before(:each) do
        @pid, @beef_session, @hooked_browser = start_beef_and_hook_browser
    end

    after(:each) do
        stop_beef_and_unhook_browser(@pid, @beef_session, @hooked_browser)
    end
    
    it 'Test beef.debug module' do
        click_on_module(@beef_session, 'Debug', 'Test beef.debug')
        expect(@beef_session).to have_content('Execute', wait: PAGE_LOAD_TIMEOUT)
        expect(@beef_session).to have_content('244', wait: PAGE_LOAD_TIMEOUT) # Module ID
        expect(@beef_session).to have_content('Debug Message:', wait: PAGE_LOAD_TIMEOUT)
    end
    
    it "Load all debug modules" do
        Dir.glob("modules/debug/**/config.yaml").each do |file|
            module_yaml_data = YAML.load_file(file)
    
            module_yaml_data['beef']['module'].each do |module_key, module_value|
                module_category = module_value['category']
                module_name = module_value['name']
                # some descriptions are too long and include html tags
                module_description_sub = module_value['description'][0, 20]
    
                expect(@beef_session).to have_content(module_category, wait: PAGE_LOAD_TIMEOUT)
                expect(module_category).not_to be_nil
                expect(module_category).to be_a(String)
                expect(module_name).not_to be_nil
                expect(module_name).to be_a(String)
                expect(module_description_sub).not_to be_nil
                expect(module_description_sub).to be_a(String)
    
                click_on_module(@beef_session, 'Debug', module_name)
    
                expect(@beef_session).to have_content(module_description_sub, wait: PAGE_LOAD_TIMEOUT)
                expect(@beef_session).to have_content('Execute', wait: PAGE_LOAD_TIMEOUT)
    
                # execute the module
                @beef_session.click_on('Execute')
    
                # expect the module to make command output visible
                expect(@beef_session).to have_content('command 1', wait: PAGE_LOAD_TIMEOUT)
    
                # click on the command section to display the output
                @beef_session.all('div.x-grid3-cell-inner').each do |div|
                    if div.text == 'command 1'
                        div.click
                        break
                    end
                end
    
                if module_name == 'Return Image' # this module returns an image not a string
                    image_selector = "img[src^='data:image/png;base64,iVBORw0KGgo']"
                    expect(@beef_session).to have_css(image_selector, wait: PAGE_LOAD_TIMEOUT) 
                else
                    expect(@beef_session).to have_content('data: ', wait: PAGE_LOAD_TIMEOUT)
                end
            end
        end
    end
    
end