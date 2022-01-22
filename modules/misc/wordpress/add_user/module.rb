#
# Copyright (c) Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# This is a complete rewrite of the original module exploits/wordpress_add_admin which was not working anymore
#
#  Original Author: Daniel Reece (@HBRN8).
#  Rewritten by Erwan LR (@erwan_lr | WPScanTeam) - https://wpscan.org/
#
require_relative '../wordpress_command'

class Wordpress_add_user < WordPressCommand
  def self.options
    super() + [
      { 'name' => 'username', 'ui_label' => 'Username', 'value' => 'beef' },
      { 'name' => 'password', 'ui_label' => 'Pwd', 'value' => SecureRandom.hex(5) },
      { 'name' => 'email', 'ui_label' => 'Email', 'value' => '' },
      { 'name' => 'role',
        'type' => 'combobox',
        'ui_label' => 'Role',
        'store_type' => 'arraystore',
        'store_fields' => ['role'],
        'store_data' => [['administrator'], ['editor'], ['author'], ['contributor'], ['subscriber']],
        'value' => 'administrator',
        'valueField' => 'role',
        'displayField' => 'role',
        'mode' => 'local' }
      # { 'name' => 'domail', 'type' => 'checkbox', 'ui_label' => 'Success mail?:', 'checked' => 'true' },
      # If one day optional options are supported:
      # { 'name' => 'url', 'ui_label' => 'Website:', 'value' => '' },
      # { 'name' => 'fname', 'ui_label' => 'FirstName:', 'value' => '' },
      # { 'name' => 'lname', 'ui_label' => 'LastName:', 'value' => '' }
    ]
  end
end
