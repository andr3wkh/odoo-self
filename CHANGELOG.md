# Changelog — Odoo 18 Self-Hosted (Docker)

## 2026-04-07 — Installation Review & Completion

### Fixed
- **docker-compose.yml**: Corrected service comment from "Odoo 17" to "Odoo 18"
- **config/odoo.conf**: Fixed `addons_path` — was multiline (breaks Odoo config parser), now single-line comma-separated
- **config/odoo.conf**: Added `gevent_port = 8072` for longpolling/websocket workers
- **Dockerfile**: Added `--break-system-packages` flag to `pip3 install` (required on Debian 12+ / Odoo 18 image)
- **Dockerfile**: Added `xlsxwriter` to pip dependencies (required by `report_xlsx` and financial reports)

### Added — New OCA Modules
| Module | Repository | Purpose |
|---|---|---|
| **account-invoicing** | `OCA/account-invoicing` | Invoice workflow enhancements |
| **account-payment** | `OCA/account-payment` | Payment processing tools |
| **server-tools** | `OCA/server-tools` | Base utilities (auditlog, auto_backup, cron exclusion) |
| **web** | `OCA/web` | Backend UI improvements (responsive, dark mode, widgets) |
| **social** | `OCA/social` | Mail & messaging enhancements |
| **manufacture** | `OCA/manufacture` | Manufacturing/MRP extensions |
| **knowledge** | `OCA/knowledge` | Document management |
| **queue** | `OCA/queue` | Background job runner (queue_job) |
| **connector** | `OCA/connector` | Integration/sync framework |
| **stock-logistics-workflow** | `OCA/stock-logistics-workflow` | Picking & delivery workflow extensions |

### Added — Infrastructure
- **docker-compose.yml**: Mounted `./enterprise:/mnt/enterprise` volume for optional Enterprise addons
- **config/odoo.conf**: Added `/mnt/enterprise` to `addons_path`
- **.gitignore**: Created with rules for `.env`, `__pycache__`, IDE files, Docker volumes, and `enterprise/`

### Previously Existing (from initial setup)
These were already configured before this review:

**Docker Services:**
- PostgreSQL 16 with health checks
- Redis 7 (session store)
- Odoo 18 (custom Dockerfile)
- Nginx reverse proxy with websocket support, gzip, static file caching

**OCA Modules (16 repos):**
- payroll, hr, hr-attendance, hr-expense, hr-holidays
- account-financial-tools, account-financial-reporting, bank-payment
- server-ux, reporting-engine, mis-builder
- project, crm, purchase-workflow, sale-workflow
- stock-logistics-warehouse, partner-contact

**Configuration:**
- `odoo.conf` — 2 workers, proxy mode, memory limits, cron threads
- `nginx/odoo.conf` — reverse proxy with websocket, static caching, gzip

---

## Summary

| Category | Count |
|---|---|
| OCA module repositories | **26** |
| Docker services | **4** (Postgres, Redis, Odoo, Nginx) |
| Exposed ports | 80 (nginx), 8069 (odoo), 8072 (longpoll), 5432 (pg), 6379 (redis) |

### Next Steps
1. `docker compose build` — rebuild the image to clone all OCA repos
2. `docker compose up -d` — start all services
3. Visit `http://localhost` — create your first database
4. If you have Odoo Enterprise, place addons in the `enterprise/` directory
