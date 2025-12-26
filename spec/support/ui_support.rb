#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'rspec'
require 'rest-client'
require 'spec/support/constants.rb'

def start_beef_and_hook_browser()
    reset_beef_db
    pid = start_beef_server_and_wait
    beef_session = BeefTest.login
    hooked_browser = BeefTest.new_victim

    expect(hooked_browser).not_to be_nil
    expect(hooked_browser).to be_a(Capybara::Session)
    expect(hooked_browser).to have_content('BeEF', wait: PAGE_LOAD_TIMEOUT)

    expect(beef_session).not_to be_nil
    expect(beef_session).to be_a(Capybara::Session)
    expect(beef_session).to have_content('Hooked Browsers', wait: PAGE_LOAD_TIMEOUT)

    navigate_to_hooked_browser(beef_session)

    expect(beef_session).to have_content('Commands', wait: PAGE_LOAD_TIMEOUT)
    beef_session.click_on('Commands')

    return pid, beef_session, hooked_browser
end

def stop_beef_and_unhook_browser(pid, beef_session, hooked_browser)
    stop_beef_server(pid)
    beef_session.driver.browser.close
    hooked_browser.driver.browser.close
end

def navigate_to_hooked_browser(session, hooked_browser_text = nil)
    expect(session).to have_content('Hooked Browsers', wait: PAGE_LOAD_TIMEOUT)

    hooked_browser_text = '127.0.0.1' if hooked_browser_text.nil?
    expect(session).to have_content(hooked_browser_text, wait: BROWSER_HOOKING_TIMEOUT)

    # click on the hooked browser in the leaf
    session.all('a', text: hooked_browser_text)[1].click
    expect(session).to have_content('Commands', wait: PAGE_LOAD_TIMEOUT)
end

def navigate_to_category(session, category_name = nil)
    expect(category_name).not_to be_nil
    expect(category_name).to be_a(String)

    navigate_to_hooked_browser unless session.has_content?('Current Browser')

    # ensure the command module tree is visible
    session.click_on('Commands')
    expect(session).to have_content(category_name, wait: PAGE_LOAD_TIMEOUT)

    session.first(:link_or_button, category_name + " ").click
end

def expand_category_tree(session, category, module_name = nil)
    if category.is_a?(Array)
        category.each do |category_name|
            # find the category element and scroll to it
            session.all('div', text: category_name).each do |element|
                begin
                    element_text = element.text
                    next unless element_text.start_with?(category_name)
                    match_data = element_text.match(/\A([\w\s]+)\s\((\d+)\)\z/)
                    next unless match_data
                
                    # scroll to the element
                    session.scroll_to(element)
                rescue Selenium::WebDriver::Error::StaleElementReferenceError => e

                    puts "StaleElementReferenceError: #{element_text}"
                    puts e.message
                    next
                end
            end

            expect(session).to have_content(category_name, wait: PAGE_LOAD_TIMEOUT)
            navigate_to_category(session, category_name) unless session.has_content?(module_name)
        end
    else
        navigate_to_category(session, category) unless session.has_content?(module_name)
        expect(session).to have_content(category, wait: PAGE_LOAD_TIMEOUT)
    end
    expect(session).to have_content(module_name, wait: PAGE_LOAD_TIMEOUT)
end
        
def collapse_category_tree(session, category)
    if category.is_a?(Array)
        category.reverse.each do |category_name|
            # Collapse the sub-folder
            session.scroll_to(category_name)
            session.first(:link_or_button, category_name + " ").click
        end 
    else
        session.scroll_to(category)
        session.first(:link_or_button, category + " ").click
    end
end

def click_on_module(session, category, module_name)
    # expand the category tree to make the module visible
    expand_category_tree(session, category, module_name)
    
    # click on the module in the expanded tree
    session.scroll_to(module_name)
    expect(session).to have_content(module_name, wait: PAGE_LOAD_TIMEOUT)
    modules = session.all(:link_or_button, module_name)
    modules[0].click
end