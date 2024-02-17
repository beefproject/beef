
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
            afterrender: updateRules
        }
    });

    async function updateRules() {
        const rules = await getCurrentRules(token);
        if (rules !== null) {
            console.log(`<p>Number of Auto Run rules enabled: ${rules.length}.</p>`);
            container.update(`<p>Number of Auto Run rules enabled: ${rules.length}.</p>`);
            
            for (let i = 0; i < rules.length; i++) {
                ruleForm = new AutoRunRuleForm(rules[i], function() {console.log('delete')}, function() {console.log('update')});
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