//
// Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
 * The main Tab panel for the selected zombie.
 */
ZombieTab_DetailsTab = function(zombie) {

  var zombieDetails = new BrowserDetailsDataGrid('/api/browserdetails/' + zombie.session, 30);
  zombieDetails.border = false;

  ZombieTab_DetailsTab.superclass.constructor.call(this, {
    id: 'browser-details-tab' + zombie.session,
    layout: 'fit',
    title: 'Details',
    items: {
      layout: 'border',
      border: false,
      items:[zombieDetails]
    }
  });
};

Ext.extend(ZombieTab_DetailsTab, Ext.Panel, {} );

