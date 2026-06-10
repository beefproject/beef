# BeEF Improvement Plan
> Browser Exploitation Framework — Comprehensive roadmap for AI models and contributors

---

## Repository Overview

```
beef/
├── beef                    # Main launcher script (Ruby)
├── config.yaml             # Master configuration (credentials, HTTP, extensions)
├── core/
│   ├── main/               # Server bootstrap, configuration, models, REST API
│   │   ├── configuration.rb
│   │   ├── server.rb
│   │   ├── handlers/       # HTTP request handlers
│   │   ├── models/         # ActiveRecord models (browser, command, network, etc.)
│   │   ├── rest/           # RESTful API endpoints
│   │   └── network_stack/  # Network-level utilities
│   ├── api/                # Extension/module API surface
│   └── ruby/               # Ruby utility helpers
├── extensions/             # Optional feature extensions
│   ├── admin_ui/           # Web-based admin panel (Ext JS)
│   ├── proxy/              # Man-in-the-browser proxy
│   ├── network/            # LAN-side network scanning
│   ├── xssrays/            # XSS detection engine
│   ├── metasploit/         # Metasploit integration
│   ├── social_engineering/ # Phishing / SE modules
│   ├── dns_rebinding/      # DNS rebinding attacks
│   └── webrtc/             # WebRTC-based comms
├── modules/                # Command modules (browser, exploits, network, etc.)
│   ├── browser/            # Browser fingerprinting & info gathering
│   ├── exploits/           # Client-side exploits
│   ├── network/            # Network recon from hooked browser
│   ├── social_engineering/ # UI-level SE attacks
│   └── persistence/        # Hook persistence techniques
├── arerules/               # Autorun Engine rule definitions (JSON)
├── spec/                   # RSpec test suite
└── tools/                  # Utility scripts
```

---

## Current Configuration (config.yaml)

| Setting | Value |
|---|---|
| Version | 0.5.4.0 |
| Admin credentials | user: `ninja` / passwd: `kickass22` |
| HTTP host | 0.0.0.0:3000 |
| Admin UI path | /ui |
| WebSockets | disabled (port 61985) |
| HTTPS | disabled |
| Metasploit | disabled |
| XSS Rays | enabled |
| GeoIP | enabled |

---

## How BeEF Works (Architecture)

```
Browser visits page with <script src="http://beef-host:3000/hook.js">
        |
        v
hook.js polls BeEF server (XHR or WebSocket)
        |
        v
BeEF server (Thin/Rack, Ruby) receives hooked browser ("zombie")
        |
        v
Operator uses Admin UI (/ui) or REST API to send command modules
        |
        v
Zombie executes JS payload, returns results to BeEF server
        |
        v
Results stored in SQLite (beef.db), displayed in Admin UI
```

---

## Improvement Areas & Tasks

### 1. Security Hardening

- [ ] **Enforce strong default credentials** — reject launch if credentials match known defaults
- [ ] **Add bcrypt hashing** for stored credentials instead of plaintext in config.yaml
- [ ] **Rate-limit login attempts** on the Admin UI and REST API
- [ ] **CSRF protection** on all Admin UI POST endpoints
- [ ] **Content-Security-Policy headers** on the Admin UI
- [ ] **Restrict permitted_ui_subnet** to localhost by default; require explicit opt-in for 0.0.0.0/0
- [ ] **TLS by default** — generate a self-signed cert on first run if HTTPS is not configured
- [ ] **Audit REST API token handling** — ensure tokens expire and are rotated

**Files to touch:**
- `config.yaml` — default subnet restrictions
- `core/main/rest/` — rate limiting, token expiry
- `extensions/admin_ui/` — CSRF, CSP headers
- `core/main/configuration.rb` — credential validation on startup

---

### 2. Modern Ruby / Dependency Updates

- [ ] **Upgrade Ruby target** to 3.2+ (currently supports 3.0+); use Ractors where applicable
- [ ] **Replace Thin** with Puma or Falcon for better concurrency and HTTP/2 support
- [ ] **Update Gemfile** — audit for CVEs with `bundle audit`; pin versions
- [ ] **Replace deprecated ActiveRecord patterns** — use modern query interface
- [ ] **Remove jQuery dependency** from Admin UI; migrate to vanilla JS or a lightweight framework
- [ ] **Node.js hook build** — migrate from legacy build tooling to esbuild or Vite

**Files to touch:**
- `Gemfile`, `Gemfile.lock`
- `core/main/server.rb` — swap Thin adapter
- `extensions/admin_ui/` — frontend modernization
- `package.json` — update Node build pipeline

---

### 3. Hook (hook.js) Improvements

- [ ] **WebSocket-first** — make WebSocket the default transport, fall back to XHR
- [ ] **Reduce hook.js size** — tree-shake unused fingerprinting code; target < 20 KB minified
- [ ] **Obfuscation options** — add configurable polymorphic obfuscation to evade WAFs/AV
- [ ] **Service Worker persistence** — register a Service Worker for persistent hooking across page navigations
- [ ] **CSP bypass techniques** — document and implement JSONP/script-gadget fallbacks
- [ ] **Mobile browser support** — improve iOS Safari and Android Chrome compatibility

**Files to touch:**
- `core/main/client/` — hook source files
- `config.yaml` — `websocket.enable` default
- `extensions/evasion/` — obfuscation engine

---

### 4. Module System

- [ ] **Module metadata schema** — enforce JSON schema validation on all module `config.yaml` files
- [ ] **Module result streaming** — push results to Admin UI via WebSocket instead of polling
- [ ] **Add missing browser targets** — update modules for Chrome 120+, Firefox 120+, Safari 17+
- [ ] **Deprecate broken modules** — audit all modules in `modules/exploits/`; mark/remove those targeting EOL browsers
- [ ] **Module chaining UI** — improve Autorun Engine rule builder in Admin UI
- [ ] **New modules to add:**
  - WebAuthn/passkey fingerprinting
  - WebGPU/WebAssembly capability detection
  - Clipboard API exfiltration (where permitted)
  - Browser extension enumeration (Manifest V3 era)

**Files to touch:**
- `modules/` — per-module config.yaml and command.js files
- `arerules/` — update/add Autorun Engine rules
- `extensions/admin_ui/` — module result streaming

---

### 5. REST API

- [ ] **OpenAPI/Swagger spec** — document all endpoints in `core/main/rest/`
- [ ] **API versioning** — prefix all routes with `/api/v1/`
- [ ] **Pagination** — add `limit`/`offset` to all list endpoints (browsers, commands, logs)
- [ ] **Webhook support** — allow operators to register HTTP callbacks for zombie events
- [ ] **GraphQL endpoint** (optional) — for richer querying of hooked browser data

**Files to touch:**
- `core/main/rest/` — all `.rb` files
- Add `docs/api/openapi.yaml`

---

### 6. Admin UI (extensions/admin_ui)

- [ ] **Replace Ext JS** — Ext JS is GPL-licensed and outdated; migrate to React or Vue
- [ ] **Dark mode** — add CSS custom properties for theming
- [ ] **Real-time dashboard** — WebSocket-driven live zombie list, command queue, results
- [ ] **Mobile-responsive layout** — current UI is desktop-only
- [ ] **Keyboard shortcuts** — improve operator efficiency
- [ ] **Audit log view** — show all operator actions with timestamps

**Files to touch:**
- `extensions/admin_ui/` — all frontend assets

---

### 7. Testing & CI

- [ ] **Increase RSpec coverage** — current spec/ directory is sparse; target 80%+ coverage
- [ ] **Add integration tests** — spin up BeEF + headless browser (Playwright/Puppeteer) and verify hook execution
- [ ] **GitHub Actions pipeline** — add CI workflow: `bundle install → rubocop → rspec → security audit`
- [ ] **Mutation testing** — use `mutant` gem to validate test quality
- [ ] **Docker Compose test environment** — make it trivial to spin up a test instance

**Files to touch:**
- `spec/` — add new spec files
- `.github/workflows/` — add CI YAML
- `Dockerfile` — multi-stage build for test vs. production

---

### 8. Documentation

- [ ] **PLAN.md** (this file) — keep updated as work progresses
- [ ] **ARCHITECTURE.md** — deep-dive on request lifecycle, extension loading, module execution
- [ ] **CONTRIBUTING.md** — already exists at `.github/CONTRIBUTING.md`; expand with module authoring guide
- [ ] **Module authoring guide** — step-by-step: create config.yaml, command.js, module.rb
- [ ] **REST API reference** — generated from OpenAPI spec
- [ ] **Deployment guide** — Docker, reverse proxy (nginx/Caddy), TLS setup

---

## How to Add a New Module

1. Create directory: `modules/<category>/<module_name>/`
2. Add `config.yaml`:
   ```yaml
   beef:
     module:
       my_module:
         enable: true
         category: "Browser"
         name: "My Module"
         description: "What it does"
         authors: ["your-handle"]
         target:
           working: ["ALL"]
           not_working: []
   ```
3. Add `module.rb` — inherits from `BeEF::Core::Command`; implement `post_execute`
4. Add `command.js` — JavaScript payload executed in the hooked browser
5. Register results: call `beef.execute()` and return data via `beef.net.send()`
6. Write RSpec tests in `spec/modules/<category>/<module_name>_spec.rb`
7. Test with `./beef` and the Admin UI

---

## How to Add a New Extension

1. Create directory: `extensions/<name>/`
2. Add `extension.rb` — register with `BeEF::Extension`
3. Add `config.yaml` — set `enable: false` by default
4. Enable in master `config.yaml` under `extension:` block
5. Mount routes in `extension.rb` using Sinatra DSL
6. Add specs in `spec/extensions/<name>/`

---

## Priority Order for AI Models Working on This Codebase

1. **Security fixes first** — never ship with default credentials or open subnets in production
2. **Dependency updates** — run `bundle audit` and fix CVEs before adding features
3. **Test coverage** — do not merge new modules without corresponding specs
4. **Backwards compatibility** — the REST API and hook.js interface are consumed by external tools; version changes carefully
5. **Performance** — hook.js size and poll latency directly affect operator effectiveness

---

## Quick Start for Contributors

```bash
# Install dependencies
./install

# Configure credentials (config.yaml)
# beef.credentials.user / beef.credentials.passwd

# Run BeEF
./beef

# Admin UI
open http://localhost:3000/ui

# REST API example
TOKEN=$(curl -s http://localhost:3000/api/admin/login \
  -d '{"username":"ninja","password":"kickass22"}' \
  -H 'Content-Type: application/json' | jq -r .token)

curl http://localhost:3000/api/hooks -H "X-Auth-Token: $TOKEN"

# Run tests
bundle exec rspec
```

---

## Versioning Convention

`MAJOR.MINOR.PATCH.BUILD` — e.g., `0.5.4.0`

- MAJOR: breaking API or architecture changes
- MINOR: new features, new modules, new extensions
- PATCH: bug fixes, security patches
- BUILD: internal build counter

Bump version in `config.yaml` (`beef.version`) and `VERSION` file together.

---

*Last updated: 2026-06-10 | Maintained by BeEF contributors*
