# BeEF Module Testing Errors

This document tracks errors and issues encountered during manual testing of BeEF modules.

---

## CORS-001: Cross-Origin Scanner (CORS) Module Error

**Module**: Cross-Origin Scanner (CORS)  
**Category**: Network  
**Date**: 2026-01-04  
**Browser**: Firefox (Linux)  
**Status**: ❌ Not Passed

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
from /home/zinduolis/repos/beef/modules/network/cross_origin_scanner_cors/module.rb:24:in `post_execute'
from /home/zinduolis/repos/beef/core/main/handlers/commands.rb:59:in `setup'
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
