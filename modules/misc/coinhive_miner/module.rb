#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Coinhive_miner < BeEF::Core::Command
  def self.options
    [{ 'name'         => 'public_token',
       'description'  => 'Public Token',
       'ui_label'     => 'Public Token',
       'value'        => 'Ofh5MIvjuCBDqwJ9TCTio7TYko0ig5TV',
       'type'         => 'text' },
     { 'name'         => 'mode',
       'type'         => 'combobox',
       'ui_label'     => 'Mode',
       'store_type'   => 'arraystore',
       'store_fields' => ['mode'],
       'store_data'   => [ ['IF_EXCLUSIVE_TAB'], ['FORCE_EXCLUSIVE_TAB'], ['FORCE_MULTI_TAB'] ],
       'value'        => 'FORCE_EXCLUSIVE_TAB',
       'valueField'   => 'mode',
       'displayField' => 'mode',
       'mode'         => 'local',
       'autoWidth'    => true },
     { 'name'         => 'mobile_enabled',
       'ui_label'     => 'Run on Mobile Devices',
       'type'         => 'checkbox',
       'checked'      => false
    }]
  end
  def post_execute
    save({'result' => @datastore['result']})
  end
end
