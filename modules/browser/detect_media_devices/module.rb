#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_media_devices < BeEF::Core::Command
  def post_execute
    content = {}
    content['audioinput_count']   = @datastore['audioinput_count']   unless @datastore['audioinput_count'].nil?
    content['audioinput_labels']  = @datastore['audioinput_labels']  unless @datastore['audioinput_labels'].nil?
    content['audiooutput_count']  = @datastore['audiooutput_count']  unless @datastore['audiooutput_count'].nil?
    content['audiooutput_labels'] = @datastore['audiooutput_labels'] unless @datastore['audiooutput_labels'].nil?
    content['videoinput_count']   = @datastore['videoinput_count']   unless @datastore['videoinput_count'].nil?
    content['videoinput_labels']  = @datastore['videoinput_labels']  unless @datastore['videoinput_labels'].nil?
    content['error']              = @datastore['error']              unless @datastore['error'].nil?
    save content
  end
end
