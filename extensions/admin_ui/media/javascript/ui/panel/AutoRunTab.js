
AutoRunTab = function() {

    autoRunHtml = " \
                <div style='font:11px tahoma,arial,helvetica,sans-serif;width:500px' > \
                <p>My custom panel :)</p>\
                </div>\
                ";

    AutoRunTab.superclass.constructor.call(this, {
            region:'center',
            padding:'10 10 10 10',
            html: autoRunHtml,
            autoScroll: true,
            border: false
        });
};

Ext.extend(AutoRunTab, Ext.Panel, {}); 