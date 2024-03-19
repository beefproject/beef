#
# Copyright (c) 2006-2024 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Track_physical_movement < BeEF::Core::Command
  def self.options
    []
  end

  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
