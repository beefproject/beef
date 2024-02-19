const areNotification = {
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
    console.log(`token = ${token}`);

    try {
        var res = await fetch(`/api/autorun/rules?token=${token}`);
        if (!res.ok) {
            throw new Error(`Getting auto run rules failed with status ${res.status}`);
        }
        const data = await res.json();
        console.log("Successfully retrieved active rules.");
        console.log(data);
        const rules = JSON.parse(data.rules);

        if (data.success === true && Array.isArray(rules)) {
            console.log(rules);
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

AutoRunTab = function() {
    // RESTful API token.
    var token = BeefWUI.get_rest_token();

    // Setup container element.
    var container = new Ext.Panel({
        style: {
            font: '11px tahoma,arial,helvetica,sans-serif',
            width: '500px'
        },
        html: "<p>Loading Auto Run rules...</p>",
        listeners: {
            afterrender: loadRules
        }
    });

    async function deleteRule(id) {
        const res = await fetch(`/api/autorun/rule/${id}?token=${token}`, {method: 'DELETE'});
        if (!res.ok) {
            console.error(`Failed when deleting rule with id ${id}. Failed with status ${res.status}.`);
        }
    }

    async function addRule() {
        const res = await fetch(`/api/autorun/rule/add?token=${token}`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(areNotification)
        });
        if (!res.ok) {
            console.error(`Failed when adding a new rule with status ${res.status}.`);
        }
    }

    async function updateRule(id, newRuleData) {
        // TODO: Check if this API endpoint even exists.
        const res = await fetch(`/api/autorun/rule/${id}?token=${token}`, {
            method: 'PATCH',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(newRuleData)
        });
        if (!res.ok) {
            console.error(`Failed when adding a new rule with status ${res.status}.`);
        }
    }

    async function loadRules() {
        const rules = await getCurrentRules(token);
        if (rules !== null) {
            console.log(`<p>Number of Auto Run rules enabled: ${rules.length}.</p>`);
            container.update(`<p>Number of Auto Run rules enabled: ${rules.length}.</p>`);
            
            for (let i = 0; i < rules.length; i++) {
                ruleForm = new AutoRunRuleForm(
                    rules[i],
                    function() {deleteRule(rules[i].id)},
                    function(newRuleData) {updateRule(rules[i].id, newRuleData)},
                    addRule
                );
                container.add(ruleForm);
            }
            container.doLayout();
        } else {
            container.update("<p>Failed to load Auto Run rules.</p>");
        }
    } 

    AutoRunTab.superclass.constructor.call(this, {
            region: 'center',
            padding:'10 10 10 10',
            items: [container],
            autoScroll: true,
            border: false,
            closable: false
        });
};

Ext.extend(AutoRunTab, Ext.Panel, {}); 