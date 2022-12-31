#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Physical_location_thirdparty < BeEF::Core::Command
  def self.options
    [{
      'name' => 'api_url',
      'type' => 'combobox',
      'ui_label' => 'API',
      'store_type' => 'arraystore',
      'store_fields' => ['api_url'],
      'store_data' =>
      [
        %w[http://ip-api.com/json],
        %w[https://ip.nf/me.json],
        %w[https://ipapi.co/json],
        %w[https://geoip.tools/v1/json],
        %w[https://geoip.nekudo.com/api/],
        %w[https://extreme-ip-lookup.com/json/],
        %w[http://www.geoplugin.net/json.gp],
        %w[https://ipinfo.io/json]
      ],
      'emptyText' => 'Select an API',
      'valueField' => 'api_url',
      'displayField' => 'api_url',
      'mode' => 'local',
      'forceSelection' => 'false',
      'autoWidth' => true
    }]
  end

  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
