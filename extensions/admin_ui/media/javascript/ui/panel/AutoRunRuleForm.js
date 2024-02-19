const areNotificationUpdateTest = {
    "name": "Display an alert-----",
    "author": "mgeeky",
    "modules": [
        {
            "name": "alert_dialog",
            "condition": null,
            "options": {
                "text":"You've been BeEFed ;>"
            }
        }
    ],
    "execution_order": [0],
    "execution_delay": [0],
    "chain_mode": "nested-forward"
};
/**
 * Form for the user to read, update and delete a specific Auto Run rule.
 * 
 * rule: The object definition of this rule from the Auto Run Engine.
 * deleteFn: callback function to delete this rule.
 * updateFn: callback function to update this rule.
 */
AutoRunRuleForm = function(rule, deleteFn, updateFn, addFn) {
    const self = this;
    const ruleTextFieldId = `rule-name-${rule.id}`;
    const chainModeComboId = `rule-chain-mode-${rule.id}`;

    function handleUpdateRule() {
        // TODO: Check if inputs are valid.
        const form = self.getForm();
        const formValues = form.getValues();
        const updatedRule = {
            ...rule,
            modules: JSON.parse(rule['modules']),
            execution_delay: JSON.parse(rule['execution_delay']),
            execution_order: JSON.parse(rule['execution_order']),
            name: formValues[ruleTextFieldId],
            chain_mode: formValues[chainModeComboId]
        };
        console.log(updatedRule);
        updateFn(updatedRule);
    }

    AutoRunRuleForm.superclass.constructor.call(this, {
            padding:'10 10 10 10',
            items: [{
                xtype: 'textfield',
                id: ruleTextFieldId,
                value: rule.name ? rule.name : '',
                fieldLabel: 'Name',
            },
            {
                xtype: 'displayfield',
                fieldLabel: 'Author',
                value: rule.author ? rule.author : 'anonymous',
            },{
                xtype: 'combo',
                id: chainModeComboId,
                fieldLabel: 'Chain Mode',
                store: ['sequential', 'nested-forward'],
                queryMode: 'local', // Use local data.
                triggerAction: 'all', // Show both options instead of just the default.
                editable: false, // Disable manual text input.
                forceSelection: true,
                value: rule.chain_mode ? rule.chain_mode : 'sequential'
            }
        ],
            buttons: [{
                text: 'Delete',
                handler: deleteFn
            }, {
                text: 'Save',
                handler: handleUpdateRule
            },
            {
                text: 'Add New',
                handler: addFn
            }],
            border: false,
            closable: false
        });
};

Ext.extend(AutoRunRuleForm, Ext.FormPanel, {}); 