/**
 * Form that displays fields for a module.
 * 
 * moduleData: The object definition of this moduleData from the Auto Run Engine.
 * deleteFn: callback function to delete this moduleData.
 * moveUp: moves the module up one spot in the Auto Run execution order.
 * moveDown: moves the module down one spot in the Auto Run exection order.
 */
AutoRunModuleForm = function(moduleData, deleteFn, moveUp, moveDown, ruleId, index) {
    const moduleTextAreaId = `rule-${ruleId}-module-textarea-${index}`;
    const chainModeComboId = `rule-${ruleId}-module-combo-${index}`;

    const moduleOptionsContainer = new Ext.Panel({
        padding: '5 5 5 5',
        border: false,
        layout: 'form',
        items: [/*{
                xtype: 'combo',
                id: chainModeComboId,
                fieldLabel: 'Chain Mode',
                store: ['moduleA', 'moduleB'], // TODO: Update this to the array of commands.
                queryMode: 'local', // Use local data.
                triggerAction: 'all', // Show both options instead of just the default.
                editable: false, // Disable manual text input.
                forceSelection: true,
                value: moduleData.name,
            },*/
            {
                xtype: 'displayfield',
                fieldLabel: 'Module Name',
                value: moduleData.name,
            },
            {
                xtype: 'displayfield',
                fieldLabel: 'Module Author',
                value: moduleData.author ? moduleData.author : 'anonymous',
            }
        ]
    });

    function loadModule() {
        // TODO: Need to query module option types so that not everything is given a textfield.
        console.log("Module data:");
        console.log(moduleData);
        for (key in moduleData.options) {
            const value = moduleData.options[key];
            const inputField = new Ext.form.TextField({
                fieldLabel: key,
                value: value ? value : '',
            });
            moduleOptionsContainer.add(inputField);
        };
    }
    loadModule();

    const buttonContainer = new Ext.Container({
        layout: {
            type: 'hbox',
            pack: 'end',
        },
        items: [
            {
                xtype: 'button',
                text: 'Delete',
                handler: deleteFn,
            },{
                xtype: 'button',
                text: 'Move Forward',
                handler: moveUp,
                disabled: moveUp == undefined,
            },{
                xtype: 'button',
                text: 'Move Back',
                handler: moveDown,
                disabled: moveDown == undefined,
            }
        ]
    });


    AutoRunModuleForm.superclass.constructor.call(this, {
            padding: '10 10 10 10',
            closable: false,
            items: [
                moduleOptionsContainer,
                buttonContainer
        ]});
};

Ext.extend(AutoRunModuleForm, Ext.Panel, {}); 