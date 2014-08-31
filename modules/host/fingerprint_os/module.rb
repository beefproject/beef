#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Fingerprint_os < BeEF::Core::Command

  def post_execute
    content = {}
    content['windows_nt_version'] = @datastore['windows_nt_version'] if not @datastore['windows_nt_version'].nil?
    content['installed_patches'] = @datastore['installed_patches'] if not @datastore['installed_patches'].nil?
    if content.empty?
      content['fail'] = 'Failed to fingerprint Windows version.'
    end
    save content
  end

end
