# BeEF (Browser Exploitation Framework) - PLAN

## Overview

BeEF is a penetration testing tool that focuses on the web browser. It hooks browsers
and uses them as beachheads for launching command modules and further attacks from
within the browser context.

**Tech Stack:** Ruby 3.0+, Sinatra web framework, SQLite3 database, ActiveRercord ORM,
Thin HTTP server, Erubis templates, ExtJS frontend, EventMachine WebSocket support.

---

## 1. Architecture

```
beef/                      # Main executable (bash runner)
config.yaml                # Main configuration
core/
  bootstrap.rb             # Loads all core components
  core.rb                  # Loads models, constants, config
  main/
    server.rb              # Thin HTTP server setup, mounts handlers
    configuration.rb       # YAML config loader (singleton)
    command.rb             # Command module base class
    crypto.rb              # Secure token generation
    models/                # ActiveRecord models: HookedBrowser, Command,
                           #   CommandModule, Log, Result, Rule, Execution, etc.
    handlers/              # HTTP handlers for hook.js, commands, browser details
    network_stack/         # Asset handling, websocket, redirector
    rest/                  # RESTful API handlers (Sinatra-based)
      api.rb               # Mounts all REST handlers, permitted_source?(), timeout?()
      handlers/
        admin.rb           # POST /api/admin/login
        hookedbrowsers.rb  # GET/DELETE /api/hooks
        browserdetails.rb  # GET /api/browserdetails
        modules.rb         # GET/POST /api/modules
        categories.rb      # GET /api/categories
        logs.rb           # GET/DELETE /api/logs
        server.rb          # GET /api/server
        autorun_engine.rb  # GET/POST/DELETE /api/autorun
    autorun_engine/        # Auto-Run Rule Engine (ARE)
      engine.rb            # Rule matching, JS wrapping, chaining
      parser.rb            # Rule JSON parser
      rule_loader.rb       # Loads rules from arerules/
    console/               # CLI banner, command-line parsing
    client/                # Client-side JS files (beef.js, init.js, etc.)
  api.rb                   # API Registrar (pub/sub event system)
  api/                     # API hook modules
  extension.rb             # Extension base
  extensions.rb            # Extension loading
  module.rb               # Module base class
  modules.rb              # Module loading
  hbmanager.rb            # Hooked Browser manager
  filters/                 # Input validation filters
  settings.rb             # Deprecated settings helpers
  loader.rb               # Dependency loader
  logger.rb               # Core logger

extensions/
  admin_ui/               # Web UI (ExtJS-based C&C panel)
    extension.rb
    config.yaml
    classes/
      httpcontroller.rb   # Base HTTP controller: auth, routing, templating
      session.rb          # Session management (Singleton)
    handlers/
      ui.rb               # Rack handler that dispatches to controllers
    api/
      handler.rb          # Mounts routes, builds/minifies JS
    controllers/
      authentication/     # Login/logout, IP permit checks
        authentication.rb # index, login (creds check), logout
        index.html        # Login page template
      panel/              # Main C&C panel
      modules/            # Module management
    media/
      javascript/         # ExtJS, UI JS files
      javascript-min/     # Auto-minified JS
  demos/                  # Demo HTML pages
  events/                 # Event logging extension
  evasion/                # JS obfuscation extension
  requester/              # HTTP request forgery
  proxy/                  # Man-in-the-middle proxy
  network/                # Network fingerprinting
  metasploit/             # Metasploit integration
  social_engineering/     # Social engineering modules
  xssrays/                # XSS scanning
  dns/                    # DNS support
  dns_rebinding/          # DNS rebinding attacks
  webrtc/                 # WebRTC support
  notifications/          # Slack/Pushover notifications
  etag/                   # ETag browser fingerprinting
  customhook/             # Custom hook deployment
  qrcode/                 # QR code generation
  autoloader/             # Auto-loading modules
  s2c_dns_tunnel/         # Server-to-client DNS tunnel

modules/                  # Command modules (attack modules)
  browser/                # Browser info, fingerprinting
  chrome_extensions/      # Chrome extension attacks
  debug/                  # Debug modules
  exploits/               # Browser exploits
  host/                   # Host discovery, port scanning
  ipec/                   # Inter-protocol exploitation
  metasploit/             # Metasploit bridge
  misc/                   # Miscellaneous
  network/                # Network modules
  persistence/            # Browser persistence
  phonegap/               # Mobile attacks
  social_engineering/     # Phishing, fake dialogs

arerules/                 # Auto-Run Engine rule definitions (JSON)
  alert.json              # Example: display alert dialog
  enabled/                # Symlinks or copies of enabled rules
  get_cookie.json         # Steal cookies
  lan_*.json              # LAN scanning rules
  ...

docs/                     # JSDoc-generated documentation
spec/                     # RSpec test suite
test/                     # Unit tests
tools/                    # Utilities (csrf_to_beef, etc.)
```

---

## 2. Authentication & Session Flow

### Config-based credentials (used by both UI and REST API)

- **File:** `config.yaml` → `beef.credentials.user` / `beef.credentials.passwd`
- **Current values:** `ninja` / `kickass22`

### Admin UI login flow

1. User visits `/ui/authentication` → serves `index.html` + `web_ui_auth.js`
2. JS POSTs to `/ui/authentication/login` with `username-cfrm` / `password-cfrm`
3. `Authentication#login` (in `extensions/admin_ui/controllers/authentication/authentication.rb`):
   - Checks `permitted_source?` against `beef.restrictions.permitted_ui_subnet`
   - Rate-limits via `login_fail_delay` (1s default)
   - Compares creds against `beef.credentials.user` / `beef.credentials.passwd`
   - On success: sets `BeEF::Extension::AdminUI::Session` singleton, sets session cookie (`BEEFSESSION`)
4. Session validated via `HttpController#run` on every request

### REST API login flow

1. POST `/api/admin/login` with JSON `{"username":"ninja","password":"kickass22"}`
2. `Admin#login` (in `core/main/rest/handlers/admin.rb`):
   - Checks `permitted_source?` against IP subnet
   - Rate-limits via `api_attempt_delay`
   - Compares creds, returns `{"success":true,"token":"<token>"}` on success
   - Token is `beef.api_token` (auto-generated secure token)
3. Protected endpoints require the token via `params[:token]` check in `before` filter

---

## 3. Auto-Run Rule Engine (ARE)

The ARE automatically executes module chains when a hooked browser matches
specific browser/OS criteria.

### Rule format (JSON in `arerules/`)

```json
{
  "name": "Rule Name",
  "author": "Author",
  "modules": [
    {"name": "module_name", "condition": null, "options": {"opt1": "val1"}}
  ],
  "execution_order": [0],
  "execution_delay": [0],
  "chain_mode": "sequential" | "nested-forward"
}
```

### Chain modes
- **`sequential`**: Executes modules in order with `setTimeout` delays. No result checking.
- **`nested-forward`**: Executes modules sequentially, waits for each module's result
  via `setInterval` polling, optionally passes output as input to next module.

### Rule matching

Rules match based on:
- `browser` + `browser_version` (e.g., C 43, IE 11, ALL)
- `os` + `os_version` (e.g., Windows 10, OSX 10.10, ALL)
- Version comparison operators: `<`, `<=`, `==`, `>=`, `>`, `ALL`

### Loading rules

- `rule_loader.rb` loads JSON rules from `arerules/enabled/` into the database
- Rules are stored in the `rules` table (ActiveRecord `BeEF::Core::Models::Rule`)
- Run via `Engine#find_and_run_all_matching_rules_for_zombie(hb_id)` on hook
- API: `GET/POST/DELETE /api/autorun/rule`

---

## 4. RESTful API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/admin/login` | Authenticate, get token |
| GET | `/api/hooks` | List hooked browsers |
| DELETE | `/api/hooks` | Delete hooked browser |
| GET | `/api/hooks/:id` | Get hooked browser details |
| GET | `/api/browserdetails` | Get browser details |
| GET | `/api/modules` | List modules |
| POST | `/api/modules` | Execute module on zombie |
| GET | `/api/categories` | List module categories |
| GET | `/api/logs` | Get logs |
| DELETE | `/api/logs` | Clear logs |
| GET | `/api/server` | Server info |
| GET | `/api/autorun/rules` | List autorun rules |
| POST | `/api/autorun/rule` | Create/update rule |
| DELETE | `/api/autorun/rule/:id` | Delete rule |
| GET | `/api/autorun/rule/:id` | Get rule details |

---

## 5. Client-Side JavaScript Architecture

All client-side JS files are in `core/main/client/`:

- **`beef.js`** - Base BeEF object, getsession details
- **`init.js`** - Initialization, browser fingerprinting, callback to server
- **`browser.js`** + **`browser/`** - Browser info, popups, cookies
- **`session.js`** - Session management, polling loop
- **`net.js`** + **`net/`** - Network stack (XHR, CORS, DNS, portscanner, requester)
- **`are.js`** - Auto-Run Engine client-side execution
- **`dom.js`** - DOM manipulation
- **`encode/`** - Base64, JSON encoding
- **`logger.js`** - Client-side logging
- **`mitb.js`** - Man-in-the-browser
- **`websocket.js`** / **`webrtc.js`** - WebSocket/WebRTC transport
- **`timeout.js`** - Timeout utilities
- **`updater.js`** - Module update polling
- **`geolocation.js`** - Geolocation API
- **`hardware.js`** - Hardware info
- **`os.js`** - OS detection
- **`lib/`** - Utility libraries

The JS hook (`hook.js`) is dynamically generated at `/hook.js` and includes the
initial `beef.js` + `init.js` which fingerprints the browser, then enables modules.

---

## 6. HTTP Handler Pipeline

1. `Thin::Server` receives request
2. `Rack::URLMap` routes to the correct handler
3. For admin UI: `Handlers::UI` → `HttpController#run`:
   - `authenticate_request` (IP permit check)
   - Session validity check
   - Route to controller method
   - Render Erubis template
4. For REST API: Sinatra-based handlers with `before` filter for IP + token auth
5. For hook: `Handlers::HookedBrowsers` serves `hook.js`, receives callbacks

---

## 7. Module System

### Module structure
```
modules/<category>/<module_name>/
  config.yaml    # Module metadata (name, description, browser/OS targets)
  command.js     # JavaScript template (Erubis) executed on the hooked browser
```

### Module lifecycle
1. Module loaded from `config.yaml`, stored in `command_modules` table
2. User triggers module via admin UI or API
3. `BeEF::Core::Command` builds the JS payload with Erubis
4. `pre_send` hook called for dynamic options
5. JS sent to hooked browser via polling/WebSocket
6. Results returned and stored in `results` table

### Module options
- Each module defines its options in `config.yaml`
- Options can have default values, descriptions, and types
- `<<mod_input>>` placeholder allows chaining module output as input in ARE

---

## 8. Extension System

Extensions are loaded from `extensions/<name>/` with `extension.rb` defining
the module + `config.yaml` for configuration.

Key extensions:
- **admin_ui**: The main C&C web interface
- **evasion**: JavaScript obfuscation
- **requester**: CSRF-style requests through hooked browsers
- **proxy**: Man-in-the-middle proxy
- **network**: Network reconnaissance
- **metasploit**: MSF bridge via MSGRPC
- **social_engineering**: Fake login pages, notifications
- **xssrays**: XSS scanning from hooked browser
- **dns_rebinding**: DNS rebinding attacks

Extensions hook into the framework via `BeEF::API::Registrar`:
```ruby
BeEF::API::Registrar.instance.register(
  MyExtension, BeEF::API::Server, 'mount_handler'
)
```

---

## 9. Configuration (`config.yaml`)

Key sections:
- `beef.credentials` - UI/REST login (user/passwd)
- `beef.http` - Server host/port, hook path, websocket, HTTPS, imitation
- `beef.restrictions` - IP subnet whitelists, rate limiting
- `beef.extension` - Enable/disable extensions
- `beef.autorun` - ARE polling intervals, timeouts
- `beef.database` - SQLite DB path
- `beef.geoip` - MaxMind GeoIP database path

---

## 10. Database Schema (SQLite, ActiveRecord models)

Key tables:
- `hooked_browsers` - Zombies (IP, first/last seen, session, domain, etc.)
- `commands` - Module execution instances (data, status, creation date)
- `command_modules` - Module definitions (name, description, path, etc.)
- `results` - Module execution results
- `logs` - Event/audit logs
- `browser_details` - Fingerprinted browser attributes
- `rules` - ARE rule definitions
- `executions` - ARE execution tracking

---

## 11. Security & Permissions

- **IP subnet filtering**: Both UI and REST API check `permitted_ui_subnet`
- **Rate limiting**: Login attempts throttled via configurable delays
- **CSRF protection**: Nonce tokens for state-changing admin UI actions
- **Session cookies**: `httponly` flag set, session validated by IP + cookie
- **X-Frame-Options**: `sameorigin` set on auth/panel pages
- **API token**: Auto-generated token required for REST API after login
- **SSL/TLS**: Optional HTTPS with configurable cert/key

---

## 12. Anti-Rape Additions (Extra Hardening)

### What was changed:
- Default credentials changed from `username1`/`password1` to `ninja`/`kickass22`

### Future improvements:
- Password hashing (bcrypt) instead of plaintext comparison
- Session timeout enforcement
- Account lockout after N failed attempts
- TOTP/2FA support
- Activity audit email alerts
- Webhook notifications on new admin login
- Encrypted config values (vault integration)
- IP allowlist for hooking (restrict which origins can be hooked)
- Rate-limit per IP across all endpoints
- Fail2ban integration
- HTTPS-only session cookies

---

## 13. Development Workflow

### Prerequisites
```bash
# OS packages
sudo dnf install ruby-devel sqlite-devel libcurl-devel nodejs

# Environment setup
gem install bundler
bundle install
```

### Running
```bash
# Start BeEF
./beef

# Or with explicit config
ruby beef -c config.yaml
```

### Testing
```bash
# Run RSpec tests
bundle exec rspec

# Run specific test
bundle exec rspec spec/beef/core/main/rest/handlers/admin_spec.rb
```

### Adding a module
1. Create `modules/<category>/<module_name>/`
2. Write `config.yaml` with module metadata
3. Write `command.js` with the JavaScript payload (Erubis template)
4. Restart BeEF to load the module

### Adding an extension
1. Create `extensions/<name>/`
2. Write `config.yaml`
3. Write `extension.rb` with `BeEF::Extension` module
4. Hook into API events as needed
5. Enable in `config.yaml` under `beef.extension`

### Creating ARE rules
1. Write JSON rule file in `arerules/`
2. Place symlink/copy in `arerules/enabled/`
3. On BeEF restart, rules load into DB via `rule_loader.rb`
4. Can also be managed via REST API at `/api/autorun/rule`

---

## 14. Key File Reference

| File | Purpose |
|------|---------|
| `config.yaml` | Main configuration (creds, server, extensions) |
| `core/bootstrap.rb` | Loads all framework components |
| `core/main/server.rb` | HTTP server startup, route mounting |
| `core/main/configuration.rb` | YAML config singleton with get/set |
| `core/main/rest/handlers/admin.rb` | REST auth endpoint |
| `extensions/admin_ui/controllers/authentication/authentication.rb` | UI auth controller |
| `extensions/admin_ui/classes/httpcontroller.rb` | Base controller with auth & routing |
| `extensions/admin_ui/classes/session.rb` | Session management singleton |
| `core/main/autorun_engine/engine.rb` | ARE engine (rule matching, JS wrapping) |
| `core/main/autorun_engine/rule_loader.rb` | Rule JSON loader |
| `core/main/client/init.js` | Client-side initialization |
| `core/main/client/beef.js` | Core client-side framework |
| `core/main/client/session.js` | Client polling loop |
| `core/main/models/*.rb` | ActiveRecord database models |

---

*Generated for BeEF v0.5.4.0*
