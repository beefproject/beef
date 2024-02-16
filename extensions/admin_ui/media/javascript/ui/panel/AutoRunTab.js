
/**
 * Asynchronously returns the currently active rules in an array.
 * Empty array means no rules are active.
 * null if there was an error.
 */
getCurrentRules = async function(token) {
    console.log(`token = ${token}`);

    try {
        var res = await fetch(`/api/autorun/rule/list/all?token=${token}`)
        console.log(res.body);
        console.log("Successfully retrieved active rules.");
        if (res.body.success === true && Array.isArray(res.body.rules)) {
            console.log(res.body.rules);
            return res.body.rules;
        } else {
            console.log("No active rules.");
            return [];
        }
    } catch(error) {
        console.error(error);
        console.error("Failed to get rules.");
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
            
            //ruleTitle = document.createElement('h4');
            //ruleTitle.innerHTML = "Rule title 1";
            //container.appendChild(ruleTitle);
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