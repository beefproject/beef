/**
 * Form that displays fields for a module.
 * 
 * moduleData: The object definition of this moduleData from the Auto Run Engine.
 * deleteFn: callback function to delete this moduleData.
 * moveUp: moves the module up one spot in the Auto Run execution order.
 * moveDown: moves the module down one spot in the Auto Run exection order.
 */
AutoRunModuleForm = function(moduleData, deleteFn, moveUp, moveDown) {
    const moduleNameId = `module-name-${moduleData.id}`;
    const moduleTextAreaId = `module-name-${moduleData.id}`;
    const chainModeComboId = `module-combo-${moduleData.id}`;

    AutoRunModuleForm.superclass.constructor.call(this, {
            padding:'10 10 10 10',
            items: [{
                xtype: 'textfield',
                id: moduleNameId,
                value: moduleData.name ? moduleData.name : '',
                fieldLabel: 'Name',
            },/*{
                xtype: 'combo',
                id: chainModeComboId,
                fieldLabel: 'Chain Mode',
                store: ['sequential', 'nested-forward'],
                queryMode: 'local', // Use local data.
                triggerAction: 'all', // Show both options instead of just the default.
                editable: false, // Disable manual text input.
                forceSelection: true,
                value: moduleData.chain_mode ? moduleData.chain_mode : 'sequential'
            },*/
            {
                xtype: 'displayfield',
                fieldLabel: 'Author',
                value: moduleData.author ? moduleData.author : 'anonymous',
            },{
                xtype: 'textarea',
                id: moduleTextAreaId,
                fieldLabel: 'Module Data',
                value: moduleData ? JSON.stringify(moduleData) : '{}',
                grow: true,
                width: '80%'
            },
            {
                xtype: 'button',
                text: 'Delete',
                handler: deleteFn,
            },{
                xtype: 'button',
                text: 'Move Forward',
                handler: moveUp,
                disabled: moveUp == undefined
            },{
                xtype: 'button',
                text: 'Move Back',
                handler: moveDown,
                disabled: moveDown == undefined
            }
        ],
            border: false,
            closable: false
        });
};

Ext.extend(AutoRunModuleForm, Ext.Container, {}); 