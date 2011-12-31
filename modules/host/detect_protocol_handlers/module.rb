#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Some additional protocol handlers #
# ChromeHTML, code, Explorer.AssocProtocol.search-ms, FirefoxURL, gopher, icy, ie.http, ie.https, ie.ftp, iehistory, ierss, irc, itms, magnet, mapi, mms, mmst, mmsu, msbd, msdigitallocker, nntp, opera.protocol, outlook, pcast, rlogin, sc, search, search-ms, shout, skype, snews, steam, stssync, teamspeak, tel, telnet, tn3270, ts3file, ts3server, unsv, uvox, ventrilo, winamp, WindowsCalendar.UrlWebcal.1, WindowsMail.Url.Mailto, WindowsMail.Url.news, WindowsMail.Url.nntp, WindowsMail.Url.snews, WMP11.AssocProtocol.MMS, wpc

class Detect_protocol_handlers < BeEF::Core::Command
  
  def self.options
    return [
	{ 'ui_label'=>'Link Protocol(s)', 'name'=>'handler_protocol', 'description' => 'Comma separated list of protocol handlers', 'value'=>'http, https, ftp, file, mailto, news, feed, ldap', 'width'=>'200px' },
        { 'ui_label'=>'Link Address', 'name'=>'handler_addr', 'description' => 'Handler Address - usually an IP address or domain name. The user will see this.', 'value'=>'BeEF', 'width'=>'200px' },
    ]
  end

  def post_execute
    save({'handlers' => @datastore['handlers']})
  end
  
end
