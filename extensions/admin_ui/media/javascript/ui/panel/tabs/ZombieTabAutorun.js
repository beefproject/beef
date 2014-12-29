//
//   Copyright (c) 2006-2015 Wade Alcorn wade@bindshell.net
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
 * The command tab panel. Listing the list of commands sent to the zombie.
 * Loaded in /ui/panel/index.html
 */
function generate_form_input_field(form, input, value, disabled, zombie) {
    var input_field = null;
    var input_def = null;
    if (!input['ui_label'])
        input['ui_label'] = input['name'];

    if (!input['type'])
        input['type'] = 'textfield';

    if (!input['value'])
        input['value'] = '';

    input_def = {
        id: 'form-zombie-'+zombie.session+'-field-'+input['name'],
        name: 'txt_'+input['name'],
        fieldLabel: input['ui_label'],
        anchor:'70%',
        allowBlank: false,
        value: input['value']
    };

        // create the input field object based upon the type supplied
    switch(input['type'].toLowerCase()) {
        case 'textfield':
            input_field = new Ext.form.TextField(input_def);
            break;
        case 'textarea':
            input_field = new Ext.form.TextArea(input_def);
            break;
        case 'hidden':
            input_field = new Ext.form.Hidden(input_def);
            break;
        case 'label':
            input_def['fieldLabel'] = '';
            input_def['html'] = input['html'];
            input_field = new Ext.form.Label(input_def);
            break;
        case 'checkbox':
            input_def['name'] = 'chk_' + input['name'];
            input_field = new Ext.form.Checkbox(input_def);
            break;
        case 'checkboxgroup':
            input_def['name'] = 'chkg_' + input['name'];
            input_def['items'] = input['items'];
            input_field = new Ext.form.CheckboxGroup(input_def);
            break;
        case 'combobox':
            input_def['name'] = 'com_' + input['name'];
            input_def['triggerAction'] = 'all';

            if(input.reloadOnChange || input.defaultPayload != null) {
                // defined in msfcommand.rb
                // initially the panel will be empty so it may appear still hidden
                Ext.getCmp("payload-panel").show();
                input_def['listeners'] = {
                    // update the payload options when one of them is selected
                    'select': function(combo, value) {
                        get_dynamic_payload_details(combo.getValue(), zombie);
                    },
                    // set the default payload value as defined in defaultPayload
                    'afterrender': function(combo){
                        combo.setValue(input.defaultPayload);
                        get_dynamic_payload_details(combo.getValue(),zombie);
                    }
                };
            }

            // create store to contain options for the combo box
            input_def['store']  = new Ext.data.ArrayStore( {
                fields: input['store_fields'],
                data: input['store_data']
            });

            input_field = new Ext.form.ComboBox(input_def);
            break;

       default:
            input_field = new Ext.form.TextField(input_def);
            break;
        }

    // add the properties for the input element, for example: widths, default values and the html lables
    for(definition in input) {
        if( (typeof input[definition] == 'string') && (definition != 'type') && (definition != 'name')) {
            input_field[definition] = input[definition];
        }
    }

    if(value)
         input_field.setValue(value);
    if(disabled)
        input_field.setDisabled(true);

    form.add(input_field);
}

function get_module_details(id,token){
    var mod = null;
    var url = "/api/modules/"+id+"?token="+token;
    $jwterm.ajax({
        contentType: 'application/json',
        dataType: 'json',
        type: 'GET',
        url: url,
        async:false,
        processData: false,
        success: function(data){
            mod = data;
        }
    });
    //add module id which is not returned by the RESTful API
    mod['id'] = id;
    return mod;
}

function process_module_opts(mod){
    var mod_json = {
       'mod_id': mod['id'],
       'mod_input':[]
    };
   var opts = mod['options'];
   var label='ui_label';
   var type = 'type';
   var type_val;
   var label_val;
   var value;
   var type;
   var key = value = label = type_val = "";
   var input;

   if(opts.length > 0){
       for( var i=0;i<opts.length;i++){
           input = {};
           key = opts[i]['name'];
           value = opts[i]['value'];
           type_val = opts[i]['type'];
           label_val = opts[i][label];
           input[key]=value;
           input[label]=label_val;
           input[type] = type_val;
           mod_json['mod_input'].push(input);
       }
   }
   return mod_json;
}

function send_modules(token,module_data){
    var url = "/api/modules/multi_module"+"?token="+token;
    var payload = Ext.encode(module_data);
    $jwterm.ajax({
        contentType: 'application/json',
        data: payload,
        dataType: 'json',
        type: 'POST',
        url: url,
        async:false,
        processData: false,
        success: function(data){
            var results = data;
        }
    });
}

    /* Creates the same tree as the command module list*/
ZombieTab_Autorun = function(zombie) {

    var token = beefwui.get_rest_token();

    var details_panel = new Ext.FormPanel({
        id: "zombie-autorun_details"+zombie.session,
        title: "Module Details",
        region:'west',
        border: true,
        width: 250,
        minSize: 250,
        maxSize: 500
    });

    var list_panel = new Ext.Panel({
        id: "zombie-autorun-list"+zombie.session,
        title: "Selected Modules",
        region:'west',
        border: true,
        width: 190,
        minSize: 190,
        maxSize: 500
    });

    var command_module_tree = new Ext.tree.TreePanel({
        id: "zombie-autorun-modules"+zombie.session,
        title: "Module Tree",
        border: true,
        region: 'west',
        width: 190,
        minSize: 190,
        maxSize: 500, // if some command module names are even longer, adjust this value
        useArrows: true,
        autoScroll: true,
        animate: true,
        containerScroll: true,
        rootVisible: false,
        root: {nodeType: 'async'},
        buttons:[new Ext.Button({
            text:'Execute',
            hidden:false,
            handler:function(){
                var tree = Ext.getCmp('zombie-autorun-modules'+zombie.session);
                var sel_nodes = tree.getChecked();
                if(sel_nodes.length > 0){
                    sel_nodes.forEach(function(item){
                        if(item.hasChildNodes())
                            sel_nodes.remove(item)
                    });

                    var mods_to_send = {
                        'hb':zombie.session,
                        'modules':[]
                    };

                    Ext.each(sel_nodes,function(item){
                        var id = item.id;
                        var module = get_module_details(id,token);
                        module = process_module_opts(module);
                        mods_to_send['modules'].push(module);
                    });
                    send_modules(token,mods_to_send);
                }else {
                    //TODO: handle this case
                }
         }})],
         loader: new Ext.tree.TreeLoader({
                dataUrl: '<%= @base_path %>/modules/select/commandmodules/tree.json',
                baseParams: {zombie_session: zombie.session},
                createNode: function(attr) {
                if(attr.checked == null){attr.checked = false;}
                        return Ext.tree.TreeLoader.prototype.createNode.call(this, attr);
            },
            listeners:{
                beforeload: function(treeloader, node, callback) {
                // Show loading mask on body, to prevent the user interacting with the UI
                    treeloader.treeLoadingMask = new Ext.LoadMask(Ext.getBody(),{msg:"Please wait, command tree is loading..."});
                    treeloader.treeLoadingMask.show();
                    return true;
                },
                load: function(treeloader, node, response) {
                       // Hide loading mask after tree is fully loaded
                       treeloader.treeLoadingMask.hide();
                       //if(node.parentNode.isChecked())
                         node.getUI().toggleCheck();
                          return true;
                 }
            }
        }),
        listeners: {
            'click': function(node) {
                if(!node.hasChildNodes()){
                    details_panel.removeAll();
                    details_panel.doLayout();
                    // needs to be a functions (get_module_opts)
                    var id = node.id;
                    var module = get_module_details(id,token);
                    if(!module){
                        Ext.beef.msg("Module is null");
                    }

                    var inputs = module['options'];
                    Ext.each(inputs,function(item){
                        generate_form_input_field(details_panel,item,item['value'],false,zombie);
                    });

                    details_panel.doLayout();
               }
            },
            'afterrender' : function() {},
            'selectionchange' : function() {},
            'activate' : function() {},
            'select' : function() {},
            'keyup' : function() {},
            'render' : function(c) { c.getEl().on('keyup', function() {});},
            'checkchange':function(node,check){
                if(check){
                    // expand and select all nodes under a parent
                    if(node.isExpandable())
                        node.expand();
                        node.cascade(function(n){
                        if(!n.getUI().isChecked())
                            n.getUI().toggleCheck();
                    });
                }
                // Collapse and deselect all children under the parent
                else{
                    node.cascade(function(n){
                    if(n.getUI().isChecked())
                        n.getUI().toggleCheck();
                    });
                    node.collapse();
                }
            }
        }
    });

    ZombieTab_Autorun.superclass.constructor.call(this, {
        id: 'zombie-'+zombie.session+'-autorun-panel',
        title:'Autorun',
        layout: 'hbox',
        hidden: true,
        layoutConfig:{align:'stretch'},
        region: 'center',
        selModel:Ext.tree.MultiSelectionModel,
        items:[command_module_tree,details_panel]
    });
};

Ext.extend(ZombieTab_Autorun, Ext.Panel, {
    listeners: {close: function(panel) {}}
});

