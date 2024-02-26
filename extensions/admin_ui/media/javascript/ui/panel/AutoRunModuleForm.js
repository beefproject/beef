
loadModuleInfo = async function(token, moduleName) {
    let moduleId = null;
    try {
        const searchResponse = await fetch(`/api/modules/search/${moduleName}?token=${token}`);
        if (!searchResponse.ok) {
            throw new Error(`Getting auto run rules failed with status ${searchResponse.status}`);
        }
        const searchData = await searchResponse.json();
        console.log("Search data:");
        console.log(searchData);
        if (typeof searchData.id === 'number') {
            moduleId = searchData.id;
        } else {
            throw new Error("Searching module name failed.");
        }

        // DEBUG log
        console.log(`Successfully retrieved module id for ${moduleName} = ${moduleId}`);

        const infoResponse = await fetch(`/api/modules/${moduleId}?token=${token}`);
        const infoData = await infoResponse.json();
        if (!infoData) {
            throw new Error(`Module with name ${moduleName} and ID ${moduleId} couldn't be retrived.`);
        }
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
AutoRunModuleForm = function(moduleData, deleteFn, moveUp, moveDown, ruleId, index) {
    const moduleTextAreaId = `rule-${ruleId}-module-textarea-${index}`;
    const chainModeComboId = `rule-${ruleId}-module-combo-${index}`;
    const token = BeefWUI.get_rest_token();

    // TODO: Change the module.
    /*
    const moduleSelect = new Ext.form.ComboBox({
        fieldLabel: 'Command Module',
        store: [{name: 'hi', id: 1}], 
        queryMode: 'local',  // Set the queryMode to 'remote'
        displayField: 'name',
        valueField: 'id',
        editable: false,  // Disable manual editing of the field
        forceSelection: true,  // Force selection from the list
        //listeners: {
        //    render: function (combo) {
        //        combo.setValue(moduleData.name);
        //    },
        //    select: function(combo, newValue, oldValue) {
        //        if (newValue) {
        //            console.log("Combo value selected.");
        //        }
        //    }
        //}
    });
    */

    const moduleOptionsContainer = new Ext.Panel({
        title: `${moduleData.name}`,
        padding: '10 10 10 10',
        layout: 'form',
        border: false,
        items: [
            {
                xtype: 'displayfield',
                fieldLabel: 'Module Name',
                value: moduleData.name,
            },
            {
                xtype: 'displayfield',
                fieldLabel: 'Module Author',
                value: moduleData.author ? moduleData.author : 'anonymous',
            },
        ],
        listeners: {
            afterrender: loadModule
        }
    });

    async function loadModule() {
        const moduleInfo = await loadModuleInfo(token, moduleData.name);
        if (!moduleInfo) {
           moduleOptionsContainer.update("<p>Failed to load module information.</p>"); 
           return;
        }

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
                //moduleSelect,
                moduleOptionsContainer,
                buttonContainer
        ]
    });
};

Ext.extend(AutoRunModuleForm, Ext.Container, {}); 