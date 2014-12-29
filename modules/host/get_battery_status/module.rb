#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_battery_status < BeEF::Core::Command

  def post_execute
    content = {}
    content['chargingStatus'] = @datastore['chargingStatus']
    content['batteryLevel'] = @datastore['batteryLevel']
    content['chargingTime'] = @datastore['chargingTime']
    content['dischargingTime'] = @datastore['dischargingTime']
    save content
  end

end
