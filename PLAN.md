# BeEF (Browser Exploitation Framework) - Comprehensive Development Plan

> **Version:** 0.5.4.0  
> **Purpose:** This document serves as a living roadmap for AI models, contributors, and maintainers to understand, improve, and extend the BeEF framework.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Overview](#architecture-overview)
3. [Directory Structure](#directory-structure)
4. [Current Configuration](#current-configuration)
5. [Core Subsystems](#core-subsystems)
6. [Extension System](#extension-system)
7. [Module System](#module-system)
8. [RESTful API](#restful-api)
9. [Technology Stack](#technology-stack)
10. [Improvement Areas](#improvement-areas)
11. [Security Hardening Plan](#security-hardening-plan)
12. [New Features Roadmap](#new-features-roadmap)
13. [Testing Strategy](#testing-strategy)
14. [Contribution Guidelines for AI Models](#contribution-guidelines-for-ai-models)

---

## Project Overview

BeEF is an open-source penetration testing tool focused on web browser exploitation. It allows security professionals to assess the security posture of a target environment using client-side attack vectors. BeEF hooks one or more web browsers and uses them as beachheads for launching directed command modules and further attacks from within the browser context.

**Key Facts:**
- Written primarily in Ruby (backend) and JavaScript (hook/client)
- Uses SQLite for persistent storage via ActiveRecord
- Thin/Rack HTTP server
- Modular extension and module system
- RESTful API for external integration
- WebSocket support for real-time browser communication

---

## Architecture Overview

```
BeEF
├── HTTP Server (Thin/Rack)         # Web server serving hook.js and admin UI
│   ├── Hook Handler                # Serves and manages hook.js
│   ├── Admin UI Extension          # Web-based control panel (Sinatra)
│   └── RESTful API                 # JSON REST API for programmatic control
├── Core Engine
│   ├── Configuration System        # YAML-based config with runtime overrides
│   ├── Extension Loader            # Dynamically loads enabled extensions
│   ├── Module Loader               # Dynamically loads attack/utility modules
│   ├── Autorun Rule Engine (ARE)   # Rule-based automated module execution
│   └── Database Layer              # SQLite via ActiveRecord + otr-activerecord
├── Extensions                      # Pluggable feature sets (proxy, network, etc.)
└── Modules                         # Attack/utility modules sent to hooked browsers
```

### Request Flow

1. A target browser loads a page containing `<script src="http://beefserver/hook.js"></script>`
2. `hook.js` registers the browser with BeEF via `/init` (POST with fingerprint data)
3. The hooked browser polls BeEF at regular intervals (XHR or WebSocket) for pending commands
4. The operator selects a module in the Admin UI or via REST API
5. BeEF queues the module's JavaScript payload for the target browser
6. On next poll, the browser executes the payload and returns results
7. Results are stored in SQLite and displayed in the Admin UI

---

## Directory Structure

```
/
├── beef                        # Main entry point (Ruby executable)
├── config.yaml                 # Primary configuration file
├── Gemfile / Gemfile.lock      # Ruby dependency definitions
├── Rakefile                    # Rake task definitions
├── VERSION                     # Current version string
├── install                     # OS-level installation script
├── update-beef                 # Git pull + bundle update helper
├── beef_cert.pem / beef_key.pem # Default TLS certificate (dev only)
├── arerules/                   # Autorun Rule Engine rule files
├── core/
│   ├── api.rb                  # API registrar (event bus / hook system)
│   ├── api/                    # API hook definitions
│   ├── bootstrap.rb            # Framework boot sequence
│   ├── extension.rb / extensions.rb  # Extension base classes
│   ├── filters.rb / filters/   # Input validation and filtering
│   ├── loader.rb               # Core require loader
│   ├── module.rb / modules.rb  # Module base class and loader
│   ├── ruby/                   # Ruby stdlib extensions (deep_merge, etc.)
│   ├── settings.rb             # Runtime settings
│   └── main/
│       ├── ar-migrations/      # ActiveRecord DB migration files
│       ├── autorun_engine/     # ARE engine implementation
│       ├── client/             # Client-side JS generation helpers
│       ├── command.rb          # Command queueing logic
│       ├── configuration.rb    # YAML config loader and accessor
│       ├── console/            # CLI argument parsing and banners
│       ├── constants/          # Framework-wide constants
│       ├── crypto.rb           # Secure token and random string generation
│       ├── geoip.rb            # GeoIP database lookup wrapper
│       ├── handlers/           # HTTP request handlers
│       │   ├── browserdetails.rb   # Hooked browser fingerprinting handler
│       │   ├── commands.rb         # Command retrieval handler
│       │   └── hookedbrowsers.rb   # Hook.js serving and session management
│       ├── migration.rb        # DB migration manager
│       ├── models/             # ActiveRecord models
│       │   ├── browserdetails.rb
│       │   ├── command.rb
│       │   ├── commandmodule.rb
│       │   ├── execution.rb
│       │   ├── hookedbrowser.rb
│       │   └── log.rb
│       ├── network_stack/      # Asset handler and WebSocket stack
│       ├── rest/               # RESTful API Sinatra handlers
│       │   └── handlers/
│       │       ├── admin.rb
│       │       ├── autorun_engine.rb
│       │       ├── hookedbrowsers.rb
│       │       ├── logs.rb
│       │       ├── modules.rb
│       │       └── server.rb
│       ├── router/             # URL routing
│       └── server.rb           # Thin HTTP server wrapper
├── extensions/
│   ├── admin_ui/               # Web-based admin control panel
│   ├── customhook/             # Custom hook.js content injection
│   ├── demos/                  # Demo pages for testing hooks
│   ├── dns/                    # DNS server extension
│   ├── dns_rebinding/          # DNS rebinding attack support
│   ├── evasion/                # Evasion techniques
│   ├── events/                 # Event system
│   ├── metasploit/             # Metasploit Framework integration
│   ├── network/                # Network discovery helpers
│   ├── notifications/          # Slack/Pushover notifications
│   ├── proxy/                  # HTTP proxy extension
│   ├── qrcode/                 # QR code generation
│   ├── requester/              # HTTP request forging
│   ├── social_engineering/     # Social engineering pages
│   ├── webrtc/                 # WebRTC-based communication
│   └── xssrays/                # XSS vulnerability scanner
├── modules/
│   ├── browser/                # Browser-level recon and attacks
│   ├── chrome_extensions/      # Chrome extension detection
│   ├── debug/                  # Debug/testing modules
│   ├── exploits/               # Active exploit modules (routers, apps, etc.)
│   ├── host/                   # Host-level recon
│   ├── ipec/                   # In-Page Event Collection
│   ├── metasploit/             # Metasploit bridge modules
│   ├── misc/                   # Miscellaneous modules
│   ├── network/                # Network scanning modules
│   ├── persistence/            # Browser persistence techniques
│   ├── phonegap/               # PhoneGap/Cordova-based modules
│   └── social_engineering/     # Social engineering modules
├── spec/                       # RSpec test suite
├── test/                       # Integration and Selenium tests
└── docs/                       # Generated JSDoc documentation
```

---

## Current Configuration

**Primary config file:** `config.yaml`

### Authentication

```yaml
credentials:
    user:   "ninja"
    passwd: "kickass22"
```

Authentication is checked in `extensions/admin_ui/controllers/authentication/authentication.rb` and the RESTful API handler. Both compare submitted credentials against `beef.credentials.user` and `beef.credentials.passwd` from the configuration object.

**Important:** BeEF will refuse to start if credentials are set to the old defaults `beef`/`beef`.

### Key Configuration Sections

| Section | Key Settings |
|---------|-------------|
| `beef.http` | `host`, `port` (default 3000), `hook_file`, WebSocket settings |
| `beef.credentials` | `user`, `passwd` - used for both admin UI and REST API |
| `beef.restrictions` | `permitted_hooking_subnet`, `permitted_ui_subnet` |
| `beef.database` | `file` - path to SQLite database |
| `beef.http.https` | `enable`, `key`, `cert` for TLS |
| `beef.extension` | Per-extension enable/disable and config overrides |

### Networking Defaults

- HTTP hook server: `0.0.0.0:3000`
- WebSocket: port 61985 (disabled by default)
- Admin UI base path: `/ui`
- Hook file: `/hook.js`
- XHR poll timeout: 1000ms

---

## Core Subsystems

### 1. Configuration System (`core/main/configuration.rb`)

- Singleton class; initialized once from `config.yaml`
- Uses dot-notation accessors: `config.get('beef.http.port')`
- Supports runtime overrides via `config.set(key, value)`
- Loads extension configs from `extensions/*/config.yaml` via `load_extensions_config`
- Loads module configs from `modules/**/config.yaml` via `load_modules_config`

**Improvement opportunity:** Add config schema validation and typed defaults.

### 2. API Event Bus (`core/api.rb` + `core/api/`)

- Publish/subscribe system using `BeEF::API::Registrar`
- Extensions and modules register handlers for named API paths
- Fire events with `BeEF::API::Registrar.instance.fire(class, method, *args)`
- Used throughout the framework for decoupled feature integration

**Improvement opportunity:** Add async fire support; add event replay/logging for debugging.

### 3. HTTP Server (`core/main/server.rb`)

- Wraps the Thin HTTP server with a Rack::URLMap
- All URL mounts are dynamic via `server.mount(url, handler)`
- Supports HTTPS with user-provided cert/key
- Detects if default TLS cert is in use and warns

**Improvement opportunity:** Migrate from Thin to Puma for multi-threading and HTTP/2 support.

### 4. Autorun Rule Engine - ARE (`core/main/autorun_engine/`)

- Rule-based automation: trigger modules automatically when browsers hook
- Rules are YAML files placed in `arerules/enabled/`
- Supports sequential and nested-forward chain modes
- Polling interval and timeout are configurable

**Improvement opportunity:** Add a visual rule builder in the admin UI; add more chain modes.

### 5. Database Layer (`core/main/models/`)

- ActiveRecord on SQLite via `otr-activerecord`
- Models: `HookedBrowser`, `Command`, `BrowserDetails`, `Log`, `Rule`, etc.
- Migrations in `core/main/ar-migrations/`
- DB file path configured in `beef.database.file`

**Improvement opportunity:** Add PostgreSQL support for multi-user deployments; add DB encryption.

### 6. Crypto Module (`core/main/crypto.rb`)

- `secure_token(len)`: generates a cryptographically secure random hex token
- `api_token()`: generates and stores a per-run API authentication token (20 bytes)
- `random_alphanum_string(length)`: non-cryptographic random string
- `random_hex_string(length)`: SecureRandom hex string

**Improvement opportunity:** Implement bcrypt password hashing for credentials storage instead of plaintext in config.

---

## Extension System

Extensions are loaded from the `extensions/` directory. Each extension has:
- A `config.yaml` defining `enable: true/false` and extension-specific settings
- An `extension.rb` registering the extension with the BeEF API
- Optional controllers, handlers, classes, and media assets

### Enabled Extensions (defaults)

| Extension | Purpose |
|-----------|---------|
| `admin_ui` | Web-based command and control panel |
| `demos` | Demo hook pages |
| `events` | Internal event system |
| `requester` | Forge HTTP requests through hooked browsers |
| `proxy` | Proxy HTTP traffic through hooked browsers |
| `network` | Internal network discovery |
| `xssrays` | Automated XSS scanner |

### Notable Disabled Extensions

| Extension | Purpose |
|-----------|---------|
| `metasploit` | Metasploit RPC integration |
| `social_engineering` | Phishing and UI manipulation pages |
| `evasion` | Anti-detection techniques |
| `dns` | Authoritative DNS server for rebinding attacks |

### Writing a New Extension

1. Create `extensions/<name>/` directory
2. Create `config.yaml` with `beef.extension.<name>.enable: false` (disabled by default)
3. Create `extension.rb` inheriting from `BeEF::Extension::Base`
4. Register API hooks in the `initialize` method
5. Implement controllers, handlers, and assets as needed
6. Add `enable: true` in `config.yaml` or set it in main `config.yaml` under `beef.extension.<name>`

---

## Module System

Modules are the actual attack/utility payloads sent to hooked browsers. Each module has:
- A `config.yaml` with metadata (name, category, description, options, target browser restrictions)
- A command file (usually `command.js`) containing the JavaScript payload
- An optional Ruby module file for server-side logic

### Module Categories

| Category | Description |
|----------|-------------|
| `browser` | Browser recon, fingerprinting, and browser-level attacks |
| `network` | Network scanning, port scanning, DNS probing |
| `exploits` | Direct exploit payloads (router exploits, web app exploits, etc.) |
| `host` | Host OS recon (clipboard, file system access where applicable) |
| `social_engineering` | Fake dialogs, phishing overlays, clickjacking |
| `persistence` | Browser persistence (service workers, IndexedDB, etc.) |
| `phonegap` | Mobile hybrid app modules |
| `misc` | Utility modules (crypto miners, geolocation, etc.) |
| `debug` | Development and testing modules |

### Writing a New Module

1. Create `modules/<category>/<module_name>/`
2. Create `config.yaml`:
   ```yaml
   beef:
     module:
       my_module_name:
         name: 'My Module Name'
         description: 'What this module does'
         category: 'Category'
         options:
           - name: param1
             description: 'First parameter'
             ui_label: 'Parameter 1'
             value: 'default_value'
   ```
3. Create `command.js` with the JavaScript payload:
   ```javascript
   beef.execute(function() {
       // module code here
       var result = "some result";
       beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=' + result);
   });
   ```
4. Optionally create a Ruby command class for server-side processing

---

## RESTful API

Base URL: `http://<host>:<port>/api/`

Authentication: All endpoints require `?token=<api_token>` query parameter. The API token is printed to stdout on startup: `RESTful API key: <token>`.

### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/admin/ip` | Get server IP and browser count |
| GET | `/api/hooks` | List all hooked browsers |
| GET | `/api/hooks/<session>` | Get details of a specific hooked browser |
| GET | `/api/logs` | Retrieve global logs |
| GET | `/api/logs/<session>` | Retrieve logs for a hooked browser |
| GET | `/api/modules` | List all available modules |
| GET | `/api/modules/<id>` | Get module details and options |
| POST | `/api/modules/<session>/<module_id>` | Execute a module on a hooked browser |
| GET | `/api/modules/<session>/<cmd_id>` | Retrieve module execution results |
| GET | `/api/server` | Get server information |
| GET | `/api/autorun` | List Autorun rules |
| POST | `/api/autorun` | Create a new Autorun rule |

### Example: Execute a Module via REST API

```bash
# Get API token from startup output, then:
curl -H "Content-Type: application/json" \
  -d '{"module_id": 12, "param1": "value"}' \
  'http://localhost:3000/api/modules/<browser_session>/<module_id>?token=<api_token>'
```

---

## Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | Ruby | 3.0+ |
| HTTP Server | Thin | ~1.8 |
| Web Framework | Sinatra | ~3.2 |
| Rack | Rack | ~2.2 |
| Database | SQLite3 | ~2.5 |
| ORM | ActiveRecord | ~7.2 |
| WebSocket | em-websocket | ~0.5.3 |
| JS Minification | Uglifier | ~4.2 |
| GeoIP | maxmind-db | ~1.2 |
| Linting | RuboCop | ~1.70.0 |
| Testing | RSpec | ~3.13 |
| JS Runtime | Node.js | 10+ |

---

## Improvement Areas

### Priority 1 - Security

#### 1.1 Plaintext Credentials in Config
**Problem:** Credentials are stored in plaintext in `config.yaml`.  
**Solution:** Implement bcrypt hashing for the password field. On startup, check if the stored password is a bcrypt hash; if not, hash it and update the file. Compare using `BCrypt::Password.new(stored_hash) == submitted_password`.

```ruby
# Example implementation in authentication.rb
require 'bcrypt'
stored = config.get('beef.credentials.passwd')
valid = if stored.start_with?('$2a$', '$2b$')
          BCrypt::Password.new(stored) == password
        else
          stored == password
        end
```

**Files to modify:** `core/main/beef` (startup), `extensions/admin_ui/controllers/authentication/authentication.rb`, `core/main/rest/handlers/` (REST auth).

#### 1.2 API Token Persistence
**Problem:** The REST API token is regenerated on every restart, breaking integrations.  
**Solution:** Persist the API token in the database (encrypted) and optionally allow a static token in `config.yaml` for CI/CD usage.

#### 1.3 Rate Limiting
**Problem:** Login brute force protection only uses a delay; no lockout mechanism.  
**Solution:** Implement account lockout after N failed attempts using the existing `BeEF::Core::Logger` + a new `FailedAuth` model tracking IP and timestamp.

#### 1.4 CSRF Protection Enhancement
**Problem:** Session cookie is `httponly` but not `Secure` (requires HTTPS) or `SameSite` by default.  
**Solution:** Set `SameSite=Strict` and `Secure` (when HTTPS is enabled) on the session cookie in `authentication.rb`.

#### 1.5 Content Security Policy (CSP)
**Problem:** Admin UI has no Content-Security-Policy header.  
**Solution:** Add strict CSP headers in the admin UI response handlers to prevent XSS in the control panel itself.

---

### Priority 2 - Performance

#### 2.1 HTTP Server Upgrade
**Problem:** Thin is single-threaded and unmaintained.  
**Solution:** Migrate to Puma with EventMachine mode or use Falcon for fiber-based concurrency. This would improve performance when handling many simultaneously hooked browsers.

**Files to modify:** `Gemfile`, `core/main/server.rb`, `config.yaml` (add thread count settings).

#### 2.2 Database Performance
**Problem:** SQLite is a single-writer database; under heavy load (many hooked browsers), write contention can become a bottleneck.  
**Solution:** 
- Short-term: Add WAL mode (`PRAGMA journal_mode=WAL`) to SQLite configuration.
- Long-term: Add optional PostgreSQL/MySQL adapter support using environment variables.

```ruby
# Add to database setup in beef (main entry):
ActiveRecord::Base.connection.execute("PRAGMA journal_mode=WAL")
ActiveRecord::Base.connection.execute("PRAGMA synchronous=NORMAL")
```

#### 2.3 Command Queue Optimization
**Problem:** All pending commands are fetched per-poll, creating unnecessary DB reads.  
**Solution:** Implement an in-memory command cache per hooked browser session, only hitting the DB when new commands are enqueued.

---

### Priority 3 - Features

#### 3.1 WebRTC Channel (enhance existing extension)
**Problem:** The WebRTC extension exists but is limited.  
**Solution:** Improve the WebRTC extension to enable peer-to-peer C2 channel between hooked browsers, allowing lateral movement without BeEF server involvement.

#### 3.2 Module Result Streaming
**Problem:** Module results are only available after full execution.  
**Solution:** Add streaming result support for long-running modules (e.g., port scanners) using Server-Sent Events (SSE) or WebSocket push from BeEF to the admin UI.

#### 3.3 Multi-User Support
**Problem:** BeEF has only a single credential pair; multiple operators share everything.  
**Solution:** Add user management: operator roles (admin, read-only), per-user session tokens, and an audit log of operator actions.

**Files to create:** `core/main/ar-migrations/<timestamp>_create_users.rb`, `core/main/models/user.rb`  
**Files to modify:** `extensions/admin_ui/`, `core/main/rest/handlers/`

#### 3.4 Module Scheduling
**Problem:** Modules can only be manually triggered or via ARE rules.  
**Solution:** Add cron-style scheduling for modules in the ARE, enabling time-based automatic execution.

#### 3.5 Improved Browser Fingerprinting
**Problem:** Fingerprinting has not been updated to detect modern browser features (WebGPU, WASM capabilities, modern CSS features).  
**Solution:** Update `core/main/handlers/browserdetails.rb` and the client-side fingerprinting JavaScript to detect and report modern capabilities.

#### 3.6 HTTPS Enforcement Mode
**Problem:** HTTPS is optional and disabled by default.  
**Solution:** Add an HTTPS-only mode that auto-generates a self-signed cert using Ruby's OpenSSL bindings on first start, with an option to specify a Let's Encrypt managed cert via a new `certbot` integration script.

---

### Priority 4 - Developer Experience

#### 4.1 Hot-Reload for Modules
**Problem:** Adding or modifying a module requires a BeEF restart.  
**Solution:** Add a file watcher (using the `listen` gem) that detects module config/JS changes and reloads them at runtime.

#### 4.2 Module Testing Framework
**Problem:** There is no standardized way to write unit tests for individual modules.  
**Solution:** Create a `ModuleTestHelper` class in `spec/support/` that can execute a module against a mock browser and assert on the commands sent.

#### 4.3 CLI Improvements
**Problem:** The BeEF CLI only supports a handful of flags.  
**Solution:** Add subcommands: `beef status`, `beef module list`, `beef hooks list`, `beef module execute <session> <module>` - making BeEF scriptable from the shell without the REST API.

#### 4.4 Structured Logging
**Problem:** BeEF uses `print_info`/`print_error` helpers that write to stdout. Logs are not structured.  
**Solution:** Migrate to a structured logger (e.g., `semantic_logger` gem) with JSON output mode, enabling log aggregation in ELK/Splunk environments.

---

## Security Hardening Plan

Before deploying BeEF in any environment, apply the following hardening steps in order:

### Step 1: Change Default Credentials (Already Done)
- `beef.credentials.user` changed to `ninja`
- `beef.credentials.passwd` changed to `kickass22`
- **Next step:** Implement bcrypt hashing (see Priority 1.1 above)

### Step 2: Restrict Admin UI Access
In `config.yaml`, change `permitted_ui_subnet` to only allow your operator IP range:
```yaml
restrictions:
    permitted_ui_subnet: ["10.0.0.0/8", "192.168.1.0/24"]
```

### Step 3: Enable HTTPS
```yaml
http:
    https:
        enable: true
        key: "/path/to/your/private.key"
        cert: "/path/to/your/certificate.crt"
```
Generate a new self-signed cert (don't use the bundled default):
```bash
openssl req -new -x509 -days 365 -nodes -out beef_cert.pem -keyout beef_key.pem
```

### Step 4: Restrict Hook Subnet
Limit which IPs can be hooked (e.g., your lab network only):
```yaml
restrictions:
    permitted_hooking_subnet: ["10.0.0.0/8"]
    excluded_hooking_subnet: ["10.0.0.1/32"]  # exclude gateway
```

### Step 5: Enable WebSocket (Optional, for High-Traffic Labs)
```yaml
websocket:
    enable: true
    secure: true
    secure_port: 61986
```

### Step 6: Enable Reverse Proxy Support (if behind nginx/Apache)
```yaml
http:
    allow_reverse_proxy: true
    public:
        host: "beef.yourdomain.com"
        port: "443"
        https: true
```
**Warning:** Only enable `allow_reverse_proxy` if BeEF is truly behind a trusted reverse proxy; it causes BeEF to trust `X-Forwarded-For` headers.

---

## New Features Roadmap

### Short-Term (Next 1-3 Months)

- [ ] **BCrypt password hashing** - Replace plaintext password comparison with bcrypt
- [ ] **SQLite WAL mode** - Improve DB concurrency under load
- [ ] **CSP headers for Admin UI** - Add Content-Security-Policy to the control panel
- [ ] **SameSite cookie attribute** - Harden session cookie security
- [ ] **Module hot-reload** - Allow adding/editing modules without restart
- [ ] **Improved fingerprinting** - Detect WebGPU, WASM, modern CSS Grid/Container Queries

### Medium-Term (3-6 Months)

- [ ] **Multi-user support** - Admin and read-only operator roles
- [ ] **Puma migration** - Replace Thin for better concurrency
- [ ] **Streaming module results** - Real-time result delivery via SSE/WebSocket
- [ ] **Module test framework** - `ModuleTestHelper` for unit-testing JS modules
- [ ] **Structured JSON logging** - Machine-readable log output

### Long-Term (6-12 Months)

- [ ] **PostgreSQL support** - Optional alternative to SQLite for multi-user
- [ ] **Module scheduling** - Time-based ARE rules
- [ ] **BeEF CLI tool** - Shell-based control without browser UI
- [ ] **WebRTC P2P C2** - Peer-to-peer lateral movement channel
- [ ] **HTTPS auto-provisioning** - Integrated Let's Encrypt / self-signed cert generation
- [ ] **Docker Compose stack** - BeEF + nginx reverse proxy + optional ELK logging

---

## Testing Strategy

### Running Existing Tests

```bash
# Run RSpec unit tests
bundle exec rspec spec/

# Run RuboCop linter
bundle exec rubocop

# Run a specific spec file
bundle exec rspec spec/beef/configuration_spec.rb
```

### Test Suite Structure

```
spec/
├── beef/               # Unit tests for core classes
├── features/           # Capybara/Selenium integration tests
├── requests/           # HTTP request/response tests
├── support/            # Shared helpers and test configuration
│   ├── config/         # Test configuration YAML
│   └── utils/          # Test utility modules
└── spec_helper.rb      # RSpec configuration and global setup
```

### Test Coverage Gaps (Areas to Add Tests)

1. `core/main/configuration.rb` - validate all edge cases of dot-notation get/set
2. `core/main/crypto.rb` - randomness distribution and length enforcement
3. `extensions/admin_ui/controllers/authentication/` - brute force protection, session management
4. `core/main/rest/handlers/` - all REST endpoints with auth and without auth
5. Module JavaScript - add a JS test runner (e.g., Jest) for client-side module payloads
6. ARE rule evaluation - test all chain modes with mock browser responses

### Adding a New Test

For a new Ruby unit test:
```ruby
# spec/beef/my_feature_spec.rb
require 'spec_helper'

RSpec.describe BeEF::Core::MyFeature do
  describe '#my_method' do
    it 'does what it should' do
      result = described_class.new.my_method('input')
      expect(result).to eq('expected_output')
    end
  end
end
```

---

## Contribution Guidelines for AI Models

This section provides specific guidance for AI coding assistants modifying BeEF.

### Before Making Any Change

1. Read the relevant source files listed in this PLAN.md
2. Understand the BeEF API event bus - many features must register API hooks
3. Check that any new gem dependency is added to both `Gemfile` AND is compatible with Ruby 3.0+
4. Run `bundle exec rubocop` before and after changes; fix any new offenses
5. Run `bundle exec rspec spec/` and confirm no regressions

### Code Style Rules

- Follow existing RuboCop configuration (`.rubocop.yml`)
- Use `print_info`, `print_error`, `print_warning`, `print_debug` helpers for output (not `puts`/`p`)
- All new Ruby classes go in appropriate module namespace (`BeEF::Core::`, `BeEF::Extension::`, etc.)
- JavaScript for hook/modules: use vanilla JS only; no jQuery or external libraries (unavailable in the hook context)
- Module JavaScript must use `beef.net.send(url, id, result)` to return results to BeEF

### Configuration Changes

- Any new configurable option must have a default value and be read via `config.get('beef.path.to.key')`
- Document all new config keys in comments in `config.yaml` and update this PLAN.md

### Database Changes

- Any new database table requires a migration file in `core/main/ar-migrations/`
- Migration files are named `<YYYYMMDDHHMMSS>_<description>.rb`
- Use `ActiveRecord::Migration[7.2]` as the base class
- Always provide both `up` and `down` methods

### Extension Development Checklist

- [ ] `config.yaml` created with `enable: false` as default
- [ ] `extension.rb` created, inheriting from `BeEF::Extension::Base`
- [ ] Extension registered via `BeEF::API::Registrar.instance.register(...)`
- [ ] All HTTP routes mounted via `BeEF::Core::Server.instance.mount(url, handler)`
- [ ] Added to `config.yaml` extension section (main config) for user enablement
- [ ] Unit tests written in `spec/`
- [ ] No hardcoded credentials, tokens, or IP addresses

### Module Development Checklist

- [ ] `config.yaml` with correct category, name, description, and options
- [ ] `command.js` with proper `beef.execute(function() { ... })` wrapper
- [ ] `beef.net.send('<%= @command_url %>', <%= @command_id %>, result)` used for results
- [ ] No `alert()`, `console.log()` in production module code
- [ ] Module tested against Chrome and Firefox at minimum
- [ ] Browser/version restrictions added to `config.yaml` if applicable

---

## Quick Reference

### Key Configuration Paths

| Path | Purpose |
|------|---------|
| `beef.credentials.user` | Admin username |
| `beef.credentials.passwd` | Admin password |
| `beef.http.host` | Bind IP |
| `beef.http.port` | HTTP port |
| `beef.http.hook_file` | Path to hook.js |
| `beef.http.websocket.enable` | Enable WebSocket |
| `beef.http.https.enable` | Enable HTTPS |
| `beef.restrictions.permitted_ui_subnet` | Admin UI IP whitelist |
| `beef.restrictions.permitted_hooking_subnet` | Hook IP whitelist |
| `beef.database.file` | SQLite file path |
| `beef.extension.admin_ui.enable` | Enable admin panel |
| `beef.extension.metasploit.enable` | Enable Metasploit |

### Frequently Used Methods

```ruby
# Get a config value
BeEF::Core::Configuration.instance.get('beef.http.port')

# Set a config value at runtime
BeEF::Core::Configuration.instance.set('beef.http.port', '3001')

# Generate a secure token
BeEF::Core::Crypto.secure_token(20)

# Log a message to BeEF's database log
BeEF::Core::Logger.instance.register('ComponentName', 'Message here')

# Fire an API event
BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'pre_http_start', server)

# Validate an IP address
BeEF::Filters.is_valid_ip?('192.168.1.1')

# Validate a hostname
BeEF::Filters.is_valid_hostname?('example.com')
```

### Starting BeEF

```bash
# Standard start
./beef

# With custom config
./beef -c /path/to/custom_config.yaml

# With debug output
./beef -v

# Reset database on start
./beef -x

# Specify port
./beef -p 8080
```

---

*This PLAN.md was generated for BeEF v0.5.4.0. Update this document whenever significant architectural changes are made. AI models should update the relevant sections after implementing features from the roadmap.*
