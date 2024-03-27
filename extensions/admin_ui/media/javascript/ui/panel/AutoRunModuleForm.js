
loadModuleInfo = async function(token, moduleId, moduleName) {
    try {
        // If all we have is the name then we need to get the ID first.
        if (moduleId === undefined) {
            const searchResponse = await fetch(`/api/modules/search/${moduleName}?token=${token}`);
            if (!searchResponse.ok) {
                throw new Error(`Getting auto run rules failed with status ${searchResponse.status}`);
            }
            const searchData = await searchResponse.json();
            if (typeof searchData.id === 'number') {
                moduleId = searchData.id;
            } else {
                throw new Error("Searching module name failed.");
            }
        }

        const infoResponse = await fetch(`/api/modules/${moduleId}?token=${token}`);
        const infoData = await infoResponse.json();
        if (!infoData) {
            throw new Error(`Module with name ${moduleName} and ID ${moduleId} couldn't be retrived.`);
        }
        // Set the module Id incase we need it later.
        infoData.id = moduleId;
        return infoData;

    } catch(error) {
        console.error(error);
        console.error("Failed to get module information.");
        return null;
    }
}


/**
 * Form that displays fields for a module.
 * 
 * moduleData: The object definition of this moduleData from the Auto Run Engine.
 * deleteFn: callback function to delete this moduleData.
 * moveUp: moves the module up one spot in the Auto Run execution order.
 * moveDown: moves the module down one spot in the Auto Run exection order.
 */
AutoRunModuleForm = function(moduleData, deleteFn, moveUp, moveDown, ruleId, index, moduleList) {
    const moduleTextAreaId = `rule-${ruleId}-module-textarea-${index}`;
    const chainModeComboId = `rule-${ruleId}-module-combo-${index}`;
    const token = BeefWUI.get_rest_token();

    const comboStore = new Ext.data.Store({
        data: moduleList,
        reader: new Ext.data.JsonReader({
            fields: ['id', 'name'],
        }),
        proxy: new Ext.data.MemoryProxy(moduleList)
    });

    const moduleSelect = new Ext.form.ComboBox({
        fieldLabel: 'Change Module',
        store: comboStore,
        queryMode: 'local',
        displayField: 'name',
        valueField: 'id',
        editable: false,  // Disable manual editing of the field
        forceSelection: true,  // Force selection from the list
        triggerAction: 'all',
        typeAhead: true,
        listeners: {
            select: async function(combo) {
                const selectedModuleId = combo.getValue()
                const moduleInfo = await loadModuleInfo(token, selectedModuleId, undefined);
                if (!moduleInfo) {
                    console.error("Failed to load new module.");
                    return;
                }
                // Update the module data to reflect the new module.
                moduleData.name = moduleInfo.name;
                moduleData.condition = moduleInfo.condition ? moduleInfo.condition : null;
                moduleData.options = {};
                for (let i = 0; i < moduleInfo.options.length; i++) {
                    const newOption = moduleInfo.options[i];
                    moduleData.options[newOption.name] = newOption.value ? newOption.value : '';
                }
                loadModule(moduleInfo);
            }
        }
    });

    const moduleOptionsContainer = new Ext.Panel({
        title: `Module ${index + 1}`,
        tbar: [moduleSelect],
        layout: 'form',
        border: false,
        listeners: {
            afterrender: function() {loadModule(undefined)}
        }
    });

    async function loadModule(moduleInfo) {
        if (!moduleInfo)
            moduleInfo = await loadModuleInfo(token, undefined, moduleData.name);
        if (!moduleInfo) {
           moduleOptionsContainer.update("<p>Failed to load module information.</p>"); 
           return;
        }

        // Update the combobox default value to be this module.
        // Can't use the moduleData name since it doesn't match the ID.
        moduleSelect.setValue(moduleInfo.id);

        // Setup module form elements. Remove all incase we're switching from a different module.
        moduleOptionsContainer.removeAll();
        moduleOptionsContainer.add(new Ext.form.DisplayField({
            fieldLabel: 'Module Name',
            value: moduleInfo.name
        }))
        moduleOptionsContainer.add(new Ext.form.DisplayField({
            fieldLabel: 'Module Author',
            value: moduleInfo.author ? moduleInfo.author : 'anonymous'
        }))

        for (let i = 0; i < moduleInfo.options.length; i++) {
			const inputField = generate_form_input_field(
                moduleOptionsContainer,
                moduleInfo.options[i],
                moduleData.options[moduleInfo.options[i].name],
                false,
                {session: `${moduleInfo.name}-module-${index}-field-${i}`}
            );
            // Ensure any changes to the element are reflected in the newRule object.
            // When the user saves the rule the whole newRule object will be saved,
            //      including any changes made to these input fields.
            inputField.on('change', function(_inputF, newValue, oldValue) {
                moduleData.options[moduleInfo.options[i].name] = newValue;
            });

        };
        moduleOptionsContainer.doLayout();
    }

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
            items: [
                moduleOptionsContainer,
                buttonContainer
        ]
    });
};

Ext.extend(AutoRunModuleForm, Ext.Container, {}); 