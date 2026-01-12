# BeEF Module Testing Errors

This document tracks errors and issues encountered during manual testing of BeEF modules.

---

## CORS-001: Cross-Origin Scanner (CORS) Module Error

**Module**: Cross-Origin Scanner (CORS)  
**Category**: Network  
**Date**: 2026-01-04  
**Browser**: Firefox (Linux)  
**Status**: ❌ Not Passed
**Github Issue**: [#3493](https://github.com/beefproject/beef/issues/3493)

### Test Configuration
- **Scan IP range**: `127.0.0.1-127.0.0.1`
- **Ports**: `8080`
- **Test server**: Python CORS-enabled HTTP server running on localhost:8080

### Error Description
The module crashes the BeEF server thread with an `ActiveModel::UnknownAttributeError` when attempting to save scan results to the database.

**Root Cause**: The module's `post_execute` method in `module.rb:24` attempts to create a `NetworkService` record using an attribute called `type`, but the model only has an attribute called `ntype`.

### Console Error
```
ActiveModel::UnknownAttributeError: unknown attribute 'type' for BeEF::Core::Models::NetworkService.

NoMethodError: undefined method `type=' for #<BeEF::Core::Models::NetworkService id: nil, hooked_browser_id: 0, proto: "http", ip: "127.0.0.1", port: "8080", ntype: nil>
Did you mean?  ntype=
```

### Stack Trace (Key Lines)
```
from /beef/modules/network/cross_origin_scanner_cors/module.rb:24:in `post_execute'
from /beef/core/main/handlers/commands.rb:59:in `setup'
```

### Steps to Reproduce
1. Start BeEF server
2. Hook a browser (Firefox)
3. Start a CORS-enabled test server on port 8080:
   ```bash
   python3 -c "
   from http.server import HTTPServer, SimpleHTTPRequestHandler
   class CORSHandler(SimpleHTTPRequestHandler):
       def end_headers(self):
           self.send_header('Access-Control-Allow-Origin', '*')
           super().end_headers()
   HTTPServer(('127.0.0.1', 8080), CORSHandler).serve_forever()
   "
   ```
4. Execute Cross-Origin Scanner (CORS) module with:
   - Scan IP range: `127.0.0.1-127.0.0.1`
   - Ports: `8080`
5. Observe error in BeEF server console

### Expected Result
Module should return discovered CORS-enabled server at 127.0.0.1:8080 and save to database

### Actual Result
Thread terminated with exception, scan results not saved

### Suggested Fix
In `modules/network/cross_origin_scanner_cors/module.rb`, change `type:` to `ntype:` in the `NetworkService.create` call (line 24).

### Related Files
- Module source: `modules/network/cross_origin_scanner_cors/command.js`

## EXT-001: Detect Extensions Module Failure

**Module**: Detect Extensions
**Category**: Browser
**Date**: 2026-01-12
**Browser**: Firefox / Chrome (Modern)
**Status**: ❌ Not Passed
**Github Issue**: [#3494](https://github.com/beefproject/beef/issues/3494)

### Test Configuration
- **Browser**: Firefox/Chrome (Latest)
- **Extensions Installed**: Standard set (e.g. uBlock Origin, "Avast Online Security" from previous test)

### Error Description
The module executes but returns no results, even when known extensions from its list are installed.

**Root Cause**:
1.  **Outdated Extension IDs**: The module uses a hardcoded list of extension IDs (e.g., `blpcfgokakmgnkcojhhkbfbldkacnbeo` for YouTube) which may be obsolete.
2.  **Browser Security**: Modern browsers (Chrome, Firefox) block external access to extension resources (`chrome-extension://...`) unless they are explicitly listed in `web_accessible_resources` in the extension's manifest. This prevents simple enumeration by checking for the existence of files.

### Steps to Reproduce
1.  Install a known extension.
2.  Execute "Detect Extensions" module.
3.  Observe Command Results.

### Expected Result
List of detected extensions.

### Actual Result
No output / "No extensions detected".

### Suggested Fix
- Update the list of Extension IDs.
- Investigate modern side-channel attacks for extension detection.

## UI-001: Module Search Broad Matching

**Module**: BeEF UI (Module Tree Search)
**Category**: User Interface
**Date**: 2026-01-12
**Status**: ⚠️ Usability Issue
**Github Issue**: [#3495](https://github.com/beefproject/beef/issues/3495)

### Error Description
The module search bar in the "Commands" tab does not perform exact phrase matching or prioritized relevance sorting. Searching for a multi-word module name (e.g., "Detect FireBug") returns all modules matching the first word (e.g., "Detect"), resulting in a cluttered list of irrelevant modules.

### Steps to Reproduce
1.  Open the BeEF UI (`/ui/panel`).
2.  Select a hooked browser and navigate to the **Commands** tab.
3.  In the "Search capability..." input, type `Detect FireBug`.

### Expected Result
The module tree should filter to show only modules matching "Detect FireBug".

### Actual Result
The tree shows all modules containing "Detect" (e.g., "Detect Antivirus", "Detect Tor", etc.), making it difficult to find the specific module aimed for.

### Suggested Fix
- Update the javascript search filter logic to strictly match the full search string or support quoted exact searches.
- Modify the search to `AND` search terms instead of `OR` or partial matching on the first token.

## FP-001: Fingerprint Browser (PoC) Module Failure

**Module**: Fingerprint Browser (PoC)
**Category**: Browser
**Date**: 2026-01-12
**Browser**: Firefox / Chrome (Modern)
**Status**: ❌ Not Passed
**Github Issue**: [#3496](https://github.com/beefproject/beef/issues/3496)

### Test Configuration
- **Browser**: Firefox/Chrome (Latest)
- **Environment**: Local VM

### Error Description
The module executes successfully but fails to properly identify the browser type and version, returning "unknown" for both fields.

### Steps to Reproduce
1.  Start BeEF.
2.  Hook a modern browser (e.g., Firefox).
3.  Execute "Fingerprint Browser (PoC)" module.
4.  Check command results.

### Expected Result
Parsed browser name (e.g., Firefox) and version (e.g., 120.0).

### Actual Result
`data: browser_type=unknown&browser_version=unknown`

### Suggested Fix
Update the browser identification logic in `modules/browser/fingerprint_browser_poc/command.js` to support modern User-Agent strings or use a more robust detection library.

## NET-001: Fingerprint Local Network No Feedback

**Module**: Fingerprint Local Network
**Category**: Network
**Date**: 2026-01-12
**Browser**: Firefox (Linux)
**Status**: ❌ Not Passed / ⚠️ UX Issue
**Github Issue**: [#3497](https://github.com/beefproject/beef/issues/3497)

### Test Configuration
- **Scan IP range**: `common` or specific local IP (e.g., `192.168.x.x`)
- **Environment**: Local VM

### Error Description
The module executes (visible via browser DevTools generating network requests), but provides absolutely no feedback in the BeEF UI.
1.  **No Progress Indicator**: There is no indication that the scan is running, how far along it is, or if it has finished.
2.  **No Final Status**: Command results remain empty even after the scan (presumably) finishes.
3.  **No Interruption Feedback**: If the user refreshes the browser to stop the scan, the BeEF UI does not register this change or update the command status; it simply hangs or stays empty.

### Steps to Reproduce
1.  Open DevTools -> Network tab in the hooked browser.
2.  Execute "Fingerprint Local Network" (range: `common`).
3.  Observe network requests in DevTools (module is running).
4.  Observe BeEF Command module results (remains empty).
5.  Refresh hooked browser.
6.  Observe BeEF Command module results (remains empty/no status update).

### Expected Result
- The module should provide real-time or periodic status updates (e.g., "Scanning 10/20 IPs...").
- It should report "No devices found" if nothing is detected, rather than staying silent.
- It should handle browser disconnections/refreshes gracefully.

### Actual Result
BeEF UI shows command as executing (or just sent), but no data is returned to the results panel. DevTools confirms the activity, but the operator is left blind.

### Suggested Fix
- Implement `beef.net.send` calls within the JavaScript worker queue to report progress % back to the controller.
- Ensure a final summary report is sent even if 0 positive matches are found.

## NET-002: Fingerprint Routers Module Error

**Module**: Fingerprint Routers
**Category**: Network
**Date**: 2026-01-12
**Browser**: Firefox (Linux)
**Status**: ❌ Not Passed
**Github Issue**: [#3498](https://github.com/beefproject/beef/issues/3498)

### Test Configuration
- **Browser**: Firefox
- **Execution**: Standard execute (click button)

### Error Description
The module crashes the BeEF server thread with an `ActiveModel::UnknownAttributeError` when attempting to save results to the database.

**Root Cause**: The module's `post_execute` method in `modules/network/jslanscanner/module.rb:29` attempts to create a `NetworkService` record using attribute `type`, but the model expects `ntype`.

### Console Error
```
ActiveModel::UnknownAttributeError: unknown attribute 'type' for BeEF::Core::Models::NetworkService.
...
from /beef/modules/network/jslanscanner/module.rb:29:in `post_execute'
```

### Suggested Fix
In `modules/network/jslanscanner/module.rb`:
- Change line 29: `type: service` -> `ntype: service`
- Check line 37: `type: device` -> `ntype: device` (if NetworkHost model also uses ntype).



