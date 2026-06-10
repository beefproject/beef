# BeEF (Browser Exploitation Framework) — Comprehensive Development PLAN

> **Version:** 0.5.4.0  
> **Last Updated:** 2026-06-10  
> **Purpose:** This document is a living guide for AI models and human contributors to understand, maintain, update, and improve BeEF. Follow this plan sequentially or cherry-pick tasks by priority.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture Summary](#2-architecture-summary)
3. [Credential & Configuration Management](#3-credential--configuration-management)
4. [Development Environment Setup](#4-development-environment-setup)
5. [Core Subsystems](#5-core-subsystems)
6. [Extension System](#6-extension-system)
7. [Module System](#7-module-system)
8. [REST API](#8-rest-api)
9. [Testing Strategy](#9-testing-strategy)
10. [Known Technical Debt](#10-known-technical-debt)
11. [Improvement Roadmap](#11-improvement-roadmap)
12. [Security Hardening Checklist](#12-security-hardening-checklist)
13. [CI/CD Pipeline](#13-cicd-pipeline)
14. [Contributor Workflow](#14-contributor-workflow)
15. [AI Model Instructions](#15-ai-model-instructions)

---

## 1. Project Overview

**BeEF** (Browser Exploitation Framework) is a penetration testing tool focused on web browser attack surfaces. It allows security researchers to assess the security posture of a target using client-side attack vectors.

### Key Facts
- **Language:** Ruby (server-side), JavaScript (hook/client-side)
- **Runtime Requirements:** Ruby 3.0+, SQLite 3.x, Node.js 10+
- **Web Framework:** Sinatra (via Rack/Thin)
- **Database ORM:** ActiveRecord via `otr-activerecord`
- **License:** See `doc/COPYING`
- **Homepage:** https://beefproject.com
- **Repository:** https://github.com/beefproject/beef

### Entry Points
| File | Purpose |
|------|---------|
| `beef` | Main executable — starts the framework |
| `config.yaml` | Primary configuration file |
| `Gemfile` | Ruby dependency declarations |
| `install` | Dependency installation script |
| `update-beef` | Update helper script |

---

## 2. Architecture Summary

```
beef/
├── beef                          # Main launcher script
├── config.yaml                   # Master config (credentials, ports, extensions)
├── Gemfile                       # Ruby gem dependencies
├── core/
│   ├── main/
│   │   ├── configuration.rb      # Config singleton (BeEF::Core::Configuration)
│   │   ├── server.rb             # HTTP hook server (Thin/Sinatra)
│   │   ├── crypto.rb             # API token generation
│   │   ├── migration.rb          # DB schema migration helper
│   │   ├── ar-migrations/        # ActiveRecord migration files
│   │   ├── autorun_engine/       # Automatic rule-based module execution
│   │   ├── handlers/             # Request handlers (browser details, etc.)
│   │   ├── models/               # ActiveRecord models (HookedBrowser, etc.)
│   │   └── rest/                 # REST API handler classes
│   │       └── handlers/
│   │           └── admin.rb      # Admin REST endpoint (login/token)
│   └── api/                      # Internal API registrar/event system
├── extensions/
│   ├── admin_ui/                 # Web admin interface (CoffeeScript + Sinatra)
│   │   └── controllers/
│   │       └── authentication/   # Login/logout controller
│   ├── proxy/                    # HTTP proxy extension
│   ├── network/                  # Network discovery extension
│   ├── xssrays/                  # XSS vulnerability scanner
│   ├── dns/                      # DNS server extension
│   ├── requester/                # HTTP request forwarder
│   ├── websocket/                # WebSocket communication
│   └── social_engineering/       # Social engineering tools
├── modules/                      # Command modules (attack payloads)
│   ├── browser/                  # Browser-specific modules
│   ├── network/                  # Network probing modules
│   ├── exploits/                 # Exploit modules
│   ├── misc/                     # Miscellaneous modules
│   └── debug/                    # Debugging/testing modules
├── spec/                         # RSpec test suite
│   ├── spec_helper.rb            # Global test setup/helpers
│   ├── support/
│   │   ├── constants.rb          # Test constants (URLs, credentials, timeouts)
│   │   ├── beef_test.rb          # Selenium/Capybara helper methods
│   │   └── assets/               # Test config fixtures
│   └── beef/                     # Spec files mirroring source structure
└── tools/
    ├── rest_api_examples/        # REST API Ruby client examples
    └── csrf_to_beef/             # CSRF-to-BeEF conversion utilities
```

### Request Flow

```
Browser visits hook URL
        ↓
hook.js loaded → establishes persistent connection
        ↓
BeEF::Core::Server receives commands
        ↓
Modules dispatched → results collected
        ↓
Admin UI displays results via REST API + WebSocket
```

---

## 3. Credential & Configuration Management

### Current Credentials (Updated 2026-06-10)
| Field | Value |
|-------|-------|
| Username | `ninja` |
| Password | `kickass22` |

### Files That Contain / Reference Credentials

All the following files have been updated to use `ninja` / `kickass22`:

| File | Type | Notes |
|------|------|-------|
| `config.yaml` | Runtime config | Primary source of truth — read at startup |
| `spec/support/constants.rb` | Test constants | Falls back to env vars `TEST_BEEF_USER` / `TEST_BEEF_PASS` |
| `spec/spec_helper.rb` | Test helper | Sets config at test startup |
| `spec/support/assets/config_new.yaml` | Test fixture | New config format fixture |
| `spec/support/assets/config_old.yaml` | Test fixture | Old config format fixture |
| `spec/beef/api/auth_rate_spec.rb` | Test spec | Rate-limit tests assert on credentials |
| `spec/beef/core/main/autorun_engine/autorun_engine_spec.rb` | Test spec | Sets credentials before server start |
| `spec/beef/core/main/handlers/browser_details_handler_spec.rb` | Test spec | Sets credentials before server start |
| `spec/beef/extensions/requester_spec.rb` | Test spec | Sets credentials before server start |
| `spec/beef/extensions/websocket_hooked_browser_spec.rb` | Test spec | Sets credentials before server start |
| `tools/rest_api_examples/lib/beef_rest_api.rb` | API client | Default parameter values |

### Rules for Future Credential Changes

1. **Always update `config.yaml` first** — it is the runtime source of truth.
2. **Update `spec/support/constants.rb`** — the `BEEF_USER` and `BEEF_PASSWD` constants propagate to most integration tests.
3. **Update `spec/spec_helper.rb`** — the `configure_beef` method hardcodes credentials for unit tests.
4. **Search for all occurrences** before finishing:
   ```bash
   grep -rn "beef\|username1\|password1" /path/to/beef \
     --include="*.rb" --include="*.yaml" --include="*.yml" \
     | grep -i "credential\|user\|passwd\|pass"
   ```
5. **Never commit plaintext credentials to public repositories.** Use environment variables in production:
   ```bash
   TEST_BEEF_USER=ninja TEST_BEEF_PASS=kickass22 bundle exec rspec
   ```

### Environment Variable Overrides
| Variable | Default | Purpose |
|----------|---------|---------|
| `TEST_BEEF_USER` | `ninja` | Override test username |
| `TEST_BEEF_PASS` | `kickass22` | Override test password |
| `BROWSERSTACK_LOCAL_IDENTIFIER` | — | BrowserStack tunnel ID |

---

## 4. Development Environment Setup

### Prerequisites
```bash
# Ruby 3.0+
ruby --version

# SQLite 3.x
sqlite3 --version

# Node.js 10+
node --version

# Bundler
gem install bundler
```

### Installation
```bash
git clone https://github.com/beefproject/beef
cd beef
./install          # installs Ruby gems + Node dependencies
```

### Starting BeEF
```bash
./beef             # starts on http://0.0.0.0:3000 by default
# Admin UI: http://localhost:3000/ui/panel
# Hook URL: http://localhost:3000/hook.js
```

### Docker
```bash
docker build -t beef .
docker run -p 3000:3000 beef
```

### Configuration Reference (`config.yaml` key paths)
| Config Key | Default | Description |
|------------|---------|-------------|
| `beef.credentials.user` | `ninja` | Admin username |
| `beef.credentials.passwd` | `kickass22` | Admin password |
| `beef.http.host` | `0.0.0.0` | Bind address |
| `beef.http.port` | `3000` | HTTP port |
| `beef.http.public` | — | Public-facing hostname |
| `beef.http.websocket.enable` | `true` | Enable WebSocket |
| `beef.http.websocket.port` | `61985` | WebSocket port |
| `beef.database.file` | `beef.db` | SQLite database path |
| `beef.extension.admin_ui.base_path` | `/ui` | Admin UI mount path |

---

## 5. Core Subsystems

### 5.1 Configuration (`core/main/configuration.rb`)
- Singleton: `BeEF::Core::Configuration.instance`
- Loads `config.yaml` on startup
- Provides `get(key)` / `set(key, value)` methods using dot-notation paths
- **Improvement opportunity:** Add schema validation and required-field enforcement on startup.

### 5.2 HTTP Server (`core/main/server.rb`)
- Built on **Thin** (EventMachine-based) + **Sinatra**
- Mounts extensions as Rack apps
- Handles hook.js delivery, command polling, and result collection
- **Improvement opportunity:** Add rate limiting middleware globally, not just on auth endpoints.

### 5.3 Database (`core/main/ar-migrations/`)
- **ORM:** ActiveRecord via `otr-activerecord`
- **Engine:** SQLite3 (file-based, default `beef.db`)
- Migrations managed via `ActiveRecord::Migrator`
- `BeEF::Core::Migration.instance.update_db!` runs pending migrations at startup
- **Improvement opportunity:** Add PostgreSQL/MySQL support for production deployments.

### 5.4 Crypto (`core/main/crypto.rb`)
- `BeEF::Core::Crypto.api_token` — generates session API tokens
- Used to authenticate all REST API calls after login
- **Improvement opportunity:** Implement token expiration and refresh logic.

### 5.5 AutoRun Engine (`core/main/autorun_engine/`)
- Rule-based automatic module execution when a browser hooks in
- Rules defined as JSON files in `arerules/` directory
- `RuleLoader.instance.load_directory` reads all `.json` rule files
- Rule schema: `name`, `author`, `browser`, `os`, `modules`, `execution_order`, `chain_mode`
- **Improvement opportunity:** Add a REST API endpoint to CRUD autorun rules dynamically (partially implemented).

### 5.6 Authentication Flow
```
POST /api/admin/login
  → core/main/rest/handlers/admin.rb
  → checks beef.credentials.user / beef.credentials.passwd from config
  → returns JSON { success: true, token: "<api_token>" }

GET /ui/panel (browser)
  → extensions/admin_ui/controllers/authentication/authentication.rb
  → session-based login with brute-force protection
  → rate limiting: tracks failed attempts per IP
```

---

## 6. Extension System

Extensions are loaded from the `extensions/` directory. Each extension has:
- A `config.yaml` declaring `enable: true/false`
- A main Ruby file (typically `extension.rb`)
- Optional Sinatra controllers mounted under a sub-path

### Built-in Extensions
| Extension | Path | Purpose |
|-----------|------|---------|
| `admin_ui` | `/ui` | Web-based admin interface |
| `proxy` | — | HTTP proxy through hooked browser |
| `network` | — | LAN host/service discovery |
| `xssrays` | — | XSS vulnerability scanning |
| `dns` | — | Authoritative DNS server |
| `requester` | — | Forward HTTP requests through hooked browser |
| `websocket` | — | WebSocket persistent connection |
| `social_engineering` | — | Page cloning, dropper delivery |
| `events` | — | DOM event tracking |
| `evasion` | — | IDS/WAF evasion techniques |

### Adding a New Extension
1. Create `extensions/<name>/` directory
2. Add `config.yaml` with `enable: true` and metadata
3. Create `extension.rb` defining `BeEF::Extension::<Name>`
4. Register API hooks via `BeEF::API::Registrar`
5. Add spec file at `spec/beef/extensions/<name>_spec.rb`

---

## 7. Module System

Command modules are the attack payloads delivered to hooked browsers. Each module lives in `modules/<category>/<name>/`.

### Module Structure
```
modules/browser/detect_browser/
├── config.yaml       # Module metadata (name, category, target browser/OS)
├── module.rb         # Server-side Ruby (defines options, processes results)
└── command.js        # Client-side JavaScript (executes in victim browser)
```

### Module Categories
| Category | Description |
|----------|-------------|
| `browser` | Browser fingerprinting and detection |
| `network` | Network scanning and enumeration |
| `exploits` | Browser/plugin exploits |
| `misc` | Miscellaneous utilities |
| `debug` | Development and testing modules |
| `social_engineering` | Phishing and user interaction |

### Adding a New Module
1. Create `modules/<category>/<module_name>/`
2. Write `config.yaml` with: `name`, `category`, `description`, `authors`, `target` (browser/OS filters)
3. Write `module.rb`:
   - Define `class BeEF::Module::<Name> < BeEF::Core::Command`
   - Implement `pre_send` (option validation) and `post_execute` (result handling)
4. Write `command.js` — the payload executed in victim browser
5. Add unit test at `spec/beef/modules/<category>/<name>_spec.rb`

---

## 8. REST API

All REST API endpoints require a `token` parameter obtained from `/api/admin/login`.

### Authentication
```bash
curl -s -X POST http://localhost:3000/api/admin/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"ninja","password":"kickass22"}'
# Returns: {"success":true,"token":"<TOKEN>"}
```

### Key Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/admin/login` | Authenticate, get token |
| `GET` | `/api/hooks` | List hooked browsers |
| `GET` | `/api/hooks/<session>` | Get browser details |
| `GET` | `/api/logs` | Get all logs |
| `GET` | `/api/logs/<session>` | Get browser-specific logs |
| `GET` | `/api/modules` | List available modules |
| `POST` | `/api/modules/<session>/<mod_id>` | Execute module on browser |
| `GET` | `/api/network/hosts` | List discovered network hosts |
| `GET` | `/api/network/services` | List discovered services |
| `GET` | `/api/dns/ruleset` | List DNS rules |
| `POST` | `/api/dns/rule` | Add DNS rule |
| `GET` | `/api/autorun/rules` | List autorun rules |
| `POST` | `/api/autorun/rule/add` | Add autorun rule |
| `GET` | `/api/server/version` | Get BeEF version |

### Ruby API Client
See `tools/rest_api_examples/lib/beef_rest_api.rb` for a full Ruby client wrapper.

---

## 9. Testing Strategy

### Test Stack
- **Framework:** RSpec 3.x
- **Integration/UI:** Selenium WebDriver + Capybara
- **Remote Browsers:** BrowserStack (for cross-browser tests)
- **HTTP Testing:** RestClient gem

### Running Tests
```bash
# All tests
bundle exec rspec

# Specific spec file
bundle exec rspec spec/beef/api/auth_rate_spec.rb

# With custom credentials
TEST_BEEF_USER=ninja TEST_BEEF_PASS=kickass22 bundle exec rspec

# Skip BrowserStack-dependent tests
bundle exec rspec --tag ~run_on_browserstack

# Skip long-running tests
bundle exec rspec --tag ~run_on_long_tests
```

### Test Categories (RSpec Tags)
| Tag | Description |
|-----|-------------|
| `run_on_browserstack: true` | Requires BrowserStack remote browser |
| `run_on_long_tests: true` | Long-running tests (rate limits, timing) |

### Key Test Files
| File | Tests |
|------|-------|
| `spec/beef/api/auth_rate_spec.rb` | API authentication rate limiting |
| `spec/requests/login_spec.rb` | UI login/logout flows |
| `spec/beef/core/main/autorun_engine/autorun_engine_spec.rb` | AutoRun rule execution |
| `spec/beef/core/main/handlers/browser_details_handler_spec.rb` | Browser detail collection |
| `spec/beef/extensions/websocket_hooked_browser_spec.rb` | WebSocket hooking |
| `spec/beef/extensions/requester_spec.rb` | HTTP requester extension |
| `spec/beef/modules/debug/test_beef_debugs_spec.rb` | Debug module execution |

### Test Constants (`spec/support/constants.rb`)
| Constant | Value | Description |
|----------|-------|-------------|
| `BEEF_USER` | `ninja` (or `$TEST_BEEF_USER`) | Test username |
| `BEEF_PASSWD` | `kickass22` (or `$TEST_BEEF_PASS`) | Test password |
| `ATTACK_DOMAIN` | `localhost` | Attack server host |
| `VICTIM_DOMAIN` | `localhost` | Victim browser host |
| `BEEF_PORT` | `3000` | Server port |

---

## 10. Known Technical Debt

| # | Area | Issue | Priority |
|---|------|-------|----------|
| 1 | Authentication | Credentials stored as plaintext in `config.yaml` | High |
| 2 | Database | SQLite only — not suitable for multi-user/production | Medium |
| 3 | Token management | API tokens never expire | High |
| 4 | Test fixtures | `config_old.yaml` duplicates `config.yaml` structure | Low |
| 5 | JavaScript | `hook.js` has no obfuscation in development mode | Medium |
| 6 | Error handling | Some REST handlers return raw Ruby exceptions | Medium |
| 7 | Extension isolation | Extensions share global config namespace | Low |
| 8 | Documentation | Many modules lack inline documentation | Low |
| 9 | Rate limiting | Auth rate limiting only on `/api/admin/login`, not `/ui` login | High |
| 10 | HTTPS | HTTPS disabled by default; setup is manual | Medium |

---

## 11. Improvement Roadmap

### Phase 1 — Security Hardening (Immediate)
- [ ] **Hash passwords** — store bcrypt hash in config, not plaintext
- [ ] **Token expiration** — implement JWT or time-limited tokens
- [ ] **Extend rate limiting** to admin UI login (`/ui/authentication#login`)
- [ ] **HTTPS by default** — auto-generate self-signed cert on first run
- [ ] **CSRF protection** — add token validation to all state-changing UI actions
- [ ] **Content Security Policy** headers on admin UI responses

### Phase 2 — Architecture (Short-term)
- [ ] **PostgreSQL support** — add adapter config option, update migrations
- [ ] **Background job queue** — use Sidekiq/Resque for async module execution
- [ ] **WebSocket improvements** — reconnection logic, heartbeat, multiplexing
- [ ] **Module versioning** — track module API versions for compatibility
- [ ] **Plugin hot-reload** — load/unload extensions without restarting BeEF

### Phase 3 — Developer Experience (Medium-term)
- [ ] **CLI tool** — `beef-cli` for headless operation without the admin UI
- [ ] **Module scaffolding** — `beef generate module <name>` command
- [ ] **OpenAPI spec** — generate Swagger/OpenAPI docs from REST handlers
- [ ] **Docker Compose** — multi-service setup (BeEF + Metasploit + DB)
- [ ] **Improved logging** — structured JSON logs with log levels

### Phase 4 — Capabilities (Long-term)
- [ ] **Browser fingerprinting v2** — Canvas, WebGL, AudioContext fingerprinting
- [ ] **Automated exploit chaining** — AutoRun rules with conditional branching
- [ ] **Headless C2** — operate BeEF entirely via REST API without admin UI
- [ ] **Distributed hooks** — support multiple BeEF nodes behind a load balancer
- [ ] **Reporting engine** — generate PDF/HTML pentest reports from session data

---

## 12. Security Hardening Checklist

Before deploying BeEF in any environment:

- [ ] Change default credentials (✅ done: `ninja` / `kickass22`)
- [ ] Enable HTTPS (`beef.http.https.enable: true` in config.yaml)
- [ ] Restrict allowed subnets (`beef.restrictions.permitted_ui_subnet`)
- [ ] Set a strong `beef.http.websocket.secure` configuration
- [ ] Disable debug mode (`beef.debug: false`)
- [ ] Run behind a reverse proxy (nginx/Apache) with TLS termination
- [ ] Restrict database file permissions (`chmod 600 beef.db`)
- [ ] Enable IP allowlisting for admin UI access
- [ ] Review and disable unused extensions
- [ ] Rotate API tokens regularly

---

## 13. CI/CD Pipeline

### GitHub Actions (`.github/workflows/`)
The repository uses GitHub Actions for CI. Current workflows:
- Lint checks (RuboCop)
- Unit test runs
- BrowserStack integration tests (on PR)

### Recommended CI Improvements
```yaml
# Suggested additions to .github/workflows/ci.yml:
- name: Security scan
  run: bundle exec brakeman -q --no-pager

- name: Dependency audit
  run: bundle exec bundler-audit check --update

- name: Run tests with coverage
  run: bundle exec rspec --format progress
  env:
    TEST_BEEF_USER: ${{ secrets.BEEF_USER }}
    TEST_BEEF_PASS: ${{ secrets.BEEF_PASS }}
```

---

## 14. Contributor Workflow

### Before Making Changes
1. Read this PLAN.md fully
2. Check `CHANGELOG` and open GitHub Issues
3. Run the test suite to establish a baseline: `bundle exec rspec`

### Making Changes
1. Create a feature branch: `git checkout -b feature/<name>`
2. Make changes following the architecture patterns described above
3. Add/update tests for all changed code
4. Update this PLAN.md if architecture or credentials change
5. Run full test suite before submitting

### Credential Change Protocol
If credentials need to change, update ALL of the following (do not miss any):
```
config.yaml                                           ← runtime
spec/support/constants.rb                             ← test defaults
spec/spec_helper.rb                                   ← test setup
spec/support/assets/config_new.yaml                   ← test fixture
spec/support/assets/config_old.yaml                   ← test fixture
spec/beef/api/auth_rate_spec.rb                       ← hardcoded assertions
spec/beef/core/main/autorun_engine/autorun_engine_spec.rb
spec/beef/core/main/handlers/browser_details_handler_spec.rb
spec/beef/extensions/requester_spec.rb
spec/beef/extensions/websocket_hooked_browser_spec.rb
tools/rest_api_examples/lib/beef_rest_api.rb          ← API client defaults
```

### Code Style
- Ruby: follow existing style (2-space indentation, snake_case)
- JavaScript: follow existing hook.js patterns
- RSpec: use `describe` / `context` / `it` structure with descriptive names

---

## 15. AI Model Instructions

If you are an AI model reading this file, follow these instructions when working on BeEF:

### Understanding the Codebase
1. **Start here:** Read `config.yaml`, `beef` (launcher), and `core/main/server.rb`
2. **For auth issues:** Check `extensions/admin_ui/controllers/authentication/authentication.rb` and `core/main/rest/handlers/admin.rb`
3. **For test failures:** Check `spec/support/constants.rb` and `spec/spec_helper.rb` first — most test setup is there
4. **For module work:** Each module is self-contained in `modules/<category>/<name>/` with `config.yaml`, `module.rb`, `command.js`

### When Changing Credentials
- Follow the **Credential Change Protocol** in Section 14 exactly
- Use `grep -rn` to find ALL occurrences before declaring the task done
- Verify with: `grep -rn "ninja\|kickass22" . --include="*.rb" --include="*.yaml"` to confirm propagation

### When Adding Features
1. Check if a related extension already exists
2. Follow existing patterns in similar extensions/modules
3. Add RSpec tests — minimum: happy path + error case
4. Update this PLAN.md under the relevant section

### When Fixing Bugs
1. Write a failing test that reproduces the bug first
2. Fix the code
3. Confirm the test passes
4. Check if related tests are affected

### Important Patterns
```ruby
# Configuration access pattern
config = BeEF::Core::Configuration.instance
config.get('beef.credentials.user')    # read
config.set('beef.credentials.user', 'ninja')  # write (in tests only)

# API token pattern
token = BeEF::Core::Crypto.api_token  # generate for server
# Use token as ?token=<value> query param on all REST requests

# Extension registration pattern
BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'pre_http_start', http_hook_server)
```

### Do NOT
- Commit plaintext credentials to version control
- Change credentials only in `config.yaml` without updating test files
- Add modules without `config.yaml` metadata
- Skip writing tests
- Modify database migrations that have already run in production

---

## Changelog

| Date | Author | Change |
|------|--------|--------|
| 2026-06-10 | AI (goose) | Created PLAN.md; updated credentials to `ninja`/`kickass22` across all 13 files |

---

*This document should be updated every time a significant architectural change, credential rotation, or feature addition is made. Keep it accurate — other models and contributors depend on it.*
