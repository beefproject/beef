#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# This module is written by Zaur Molotnikov, 2017
# Only for the use for test purposes!
# Inspired by the coinhive miner integration (copied and modified).
#

class Cryptoloot_miner < BeEF::Core::Command
  def self.options
    [{ 'name'         => 'public_token',
       'description'  => 'Public Token',
       'ui_label'     => 'Public Token',
       'value'        => 'ae5c906cfd37610626e86e25786866d6d2ff1c258d5f',
       'type'         => 'text'
    },
    { 'name'         => 'report_interval',
       'description'  => 'Report Interval (in seconds)',
       'ui_label'     => 'Report Interval (s)',
       'value'        => '30',
       'type'         => 'text'
    }]
  end
  def post_execute
    save({'result' => @datastore['result']})
  end
end
