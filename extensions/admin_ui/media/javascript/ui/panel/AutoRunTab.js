const defaultRule = {
    "name": "Display an alert",
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
 * Asynchronously returns the currently active rules in an array.
 * Empty array means no rules are active.
 * null if there was an error.
 */
getCurrentRules = async function(token) {

    try {
        var res = await fetch(`/api/autorun/rules?token=${token}`);
        if (!res.ok) {
            throw new Error(`Getting auto run rules failed with status ${res.status}`);
        }
        const data = await res.json();
        const rules = JSON.parse(data.rules);

        if (data.success === true && Array.isArray(rules)) {
            return rules;
        }

        console.log("No active auto run rules.");
        return [];

    } catch(error) {
        console.error(error);
        console.error("Failed to get auto run rules.");
        return null;
    }
} 

getModules = async function(token) {
    try {
        var res = await fetch(`/api/modules?token=${token}`);
        if (!res.ok) {
            throw new Error(`Getting auto run rules failed with status ${res.status}`);
        }
        const modules = await res.json();

        return modules;

    } catch(error) {
        console.error(error);
        console.error("Failed to get auto run rules.");
        return null;
    }
}

AutoRunTab = function() {
    // RESTful API token.
    var token = BeefWUI.get_rest_token();

    // Heading container to describe general Auto Run state.
    var ruleLoadingState = new Ext.Container({
        html: "<p>Loading Auto Run rules...</p>",
    })
    var headingContainer = new Ext.Panel({
        style: {
            font: '11px tahoma,arial,helvetica,sans-serif'
        },
        padding:'10 10 10 10',
        border: false,
        items: [{
            xtype: 'container',
            html: '\
                <div>\
                    <h4>Auto Run Rules</h4>\
                    <p>These determine what commands run automatically when a browser is hooked.</p>\
                </div>'
        },
            ruleLoadingState,
        {
            xtype: 'button',
            text: 'Add New Rule',
            handler: addRule
        }],
        listeners: {
            afterrender: loadRules
        }
    });
    // Contains all of the rules and inputs to change each rule.
    var ruleContainer = new Ext.Panel({
        border: false,
        listeners: {
            afterrender: loadRules
        }
    });

    async function deleteRule(id) {
        const res = await fetch(`/api/autorun/rule/${id}?token=${token}`, {method: 'DELETE'});
        if (!res.ok) {
            console.error(`Failed when deleting rule with id ${id}. Failed with status ${res.status}.`);
            return;
        }
        // Update the entire rules panel. Not very efficient.
        loadRules();
    }

    async function addRule() {
        const res = await fetch(`/api/autorun/rule/add?token=${token}`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(defaultRule)
        });
        if (!res.ok) {
            console.error(`Failed when adding a new rule with status ${res.status}.`);
            return;
        }
        // Update the entire rules panel. Not very efficient.
        loadRules();
    }

    async function updateRule(id, newRuleData) {
        const res = await fetch(`/api/autorun/rule/${id}?token=${token}`, {
            method: 'PATCH',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(newRuleData)
        });
        if (!res.ok) {
            console.error(`Failed when adding a new rule with status ${res.status}.`);
            return;
        }
        // Update the entire rules panel. Not very efficient.
        loadRules();
    }

    async function loadRules() {
        let modules = [];
        let rules = [];
        try {
            modules = await getModules(token);
            rules = await getCurrentRules(token);
        } catch (error) {
            console.error(error);
            console.error("Failed to load command modules and/or rules for Auto Run.");
            ruleLoadingState.update("<p>Failed to load Auto Run rules.</p>");
            return;
        }

        if (rules !== null) {
            ruleLoadingState.update(`<p>Loaded ${rules.length} Auto Run rules.</p>`);
            ruleContainer.removeAll();
            
            for (let i = 0; i < rules.length; i++) {
                ruleForm = new AutoRunRuleForm(
                    rules[i],
                    modules,
                    function() {deleteRule(rules[i].id)},
                    function(newRuleData) {updateRule(rules[i].id, newRuleData)}
                );
                ruleContainer.add(ruleForm);
            }
            ruleContainer.doLayout();
        } else {
            ruleLoadingState.update("<p>Failed to load Auto Run rules.</p>");
        }
    } 

    AutoRunTab.superclass.constructor.call(this, {
            region: 'center',
            items: [headingContainer, ruleContainer],
            autoScroll: true,
            border: false,
            closable: false
        });
};

Ext.extend(AutoRunTab, Ext.Panel, {}); 