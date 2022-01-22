#
# Copyright (c) Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Author Erwan LR (@erwan_lr | WPScanTeam) - https://wpscan.org/
#

require 'securerandom'

class WordPressCommand < BeEF::Core::Command
  def pre_send
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/misc/wordpress/wp.js', '/wp', 'js')
  end

  # If we could retrive the hooked URL, we could try to determine the wp_path to be set below
  def self.options
    [
      { 'name' => 'wp_path', 'ui_label' => 'WordPress Path', 'value' => '/' }
    ]
  end

  # This one is triggered each time a beef.net.send is called
  def post_execute
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('wp.js')

    return unless @datastore['result']

    save({ 'result' => @datastore['result'] })
  end
end
