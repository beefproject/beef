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
 * modules: The list of all commands/modules that the user can choose from.
 * deleteFn: callback function to delete this rule.
 * updateFn: callback function to update this rule.
 */
AutoRunRuleForm = function(rule, modules, deleteFn, updateFn) {
    const self = this;
    const ruleTextFieldId = `rule-name-${rule.id}`;
    const chainModeComboId = `rule-chain-mode-${rule.id}`;
    const newRule = JSON.parse(JSON.stringify(rule));
    newRule.modules = JSON.parse(newRule['modules']);
    newRule.execution_delay = JSON.parse(newRule['execution_delay']);
    newRule.execution_order = JSON.parse(newRule['execution_order']);
    const moduleContainer = new Ext.Container({
        style: {
            padding: '10 10 10 10',
        },
        listeners: {
            afterrender: setupModuleForms 
        }
    });

    function reorderModule(index, direction) {
        // Rearrange modules into new order.
        const currentModule = newRule.modules[index];
        const newIndex = direction === 'back' ? index + 1 : index - 1;
        newRule.modules.splice(index, 1);
        newRule.modules.splice(newIndex, 0, currentModule);

        // Update DOM.
        setupModuleForms();
        moduleContainer.doLayout();
    }

    function removeModule(index) {
        // Remove element from execution_order and execution_delay arrays.
        newRule.modules.splice(index, 1);
        newRule.execution_delay.splice(index, 1);

        // Update DOM.
        setupModuleForms();
        moduleContainer.doLayout();
    }

    function addModule() {
        // New module is a copy of the last module.
        newRule.modules.push(newRule.modules[newRule.modules.length - 1]);
        newRule.execution_delay.push(newRule.execution_delay[newRule.execution_delay.length - 1]);

        // Update DOM.
        setupModuleForms();
        moduleContainer.doLayout();
    }

    function setupModuleForms() {

        moduleContainer.removeAll(true);

        // I think execution order should always be sequential.
        // The actual order comes from the modules array.
        for (let i = 0; i < newRule.modules.length; ++i) {
            const isFirstModule = i === 0;
            const isLastModule = i >= newRule.modules.length - 1;
            moduleContainer.add(new AutoRunModuleForm(
                newRule.modules[i],
                function() {removeModule(i)},
                isFirstModule ? undefined : function() {reorderModule(i, 'forward')},
                isLastModule ? undefined : function() {reorderModule(i, 'back')},
                rule.id,
                i,
                modules
            ));
        }
    }

    function handleUpdateRule() {
        // TODO: Need to overwrite module order.
        const form = self.getForm();
        const formValues = form.getValues();
        const updatedRule = {
            ...newRule,
            name: formValues[ruleTextFieldId],
            chain_mode: formValues[chainModeComboId],
            execution_order: [...Array(newRule.modules.length).keys()],
        };
        updateFn(updatedRule);
    }


    AutoRunRuleForm.superclass.constructor.call(this, {
            padding:'10 10 10 10',
            title: `Rule ${rule.id}`,
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
                xtype: 'displayfield',
                fieldLabel: 'Browser(s)',
                value: rule.browser ? rule.browser : 'All',
            },{
                xtype: 'displayfield',
                fieldLabel: 'Browser version(s)',
                value: rule.browser_version ? rule.browser_version : 'All',
            },{
                xtype: 'displayfield',
                fieldLabel: 'OS(s)',
                value: rule.os ? rule.os : 'All',
            },{
                xtype: 'displayfield',
                fieldLabel: 'OS version(s)',
                value: rule.os_version ? rule.os_version : 'All',
            },
                moduleContainer,
            {
                xtype: 'button',
                text: 'Add Module',
                handler: addModule
            },
            {
                xtype: 'combo',
                id: chainModeComboId,
                fieldLabel: 'Chain Mode',
                store: ['sequential', 'nested-forward'],
                queryMode: 'local', // Use local data.
                triggerAction: 'all', // Show both options instead of just the default.
                editable: false, // Disable manual text input.
                forceSelection: true,
                value: rule.chain_mode ? rule.chain_mode : 'sequential'
            },{
                xtype: 'displayfield',
                fieldLabel: 'Execution Order',
                value: newRule.execution_order ?
                    JSON.stringify(newRule.execution_order)
                    : 'undefined',
            },{
                xtype: 'displayfield',
                fieldLabel: 'Execution Delay',
                value: newRule.execution_delay ?
                    JSON.stringify(newRule.execution_delay)
                    : 'undefined',
            }
        ],
            buttons: [{
                text: 'Delete',
                handler: deleteFn
            }, {
                text: 'Save',
                handler: handleUpdateRule
            }],
            border: false,
            closable: false
        });
};

Ext.extend(AutoRunRuleForm, Ext.FormPanel, {}); 