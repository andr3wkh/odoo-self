# Odoo 18 Self-Hosted — Oblify bv

Self-hosted Odoo 18 Community Edition with 36 OCA addons, running on Docker with PostgreSQL 17, Redis, and Nginx.

## Stack

| Service | Image | Port |
|---------|-------|------|
| Odoo 18 | Custom (36 OCA repos) | 8069 |
| PostgreSQL 17 | postgres:17 | 5432 |
| Redis 7 | redis:7-alpine | 6379 |
| Nginx | nginx:alpine | 80 |

## Quick Start

```bash
# 1. Clone
git clone git@github.com:andr3wkh/odoo-self.git
cd odoo-self

# 2. Configure secrets
cp .env.example .env
nano .env  # fill in your passwords

# 3. Build and install (takes ~10 min first time)
bash init-fresh.sh

# 4. Access
open http://localhost:8069
```

## What's Included

### HR & People
Employee management, attendance, contracts, expenses (with approval workflows), fleet, recruitment, skills, timesheets, work entries, presence tracking, remote work, org chart, appraisals (OCA).

### Leave Management
Holidays, public holidays, attendance integration, contract-based leave.

### Payroll
OCA Payroll with multi-currency support (USD/EUR journals), salary structures, accounting integration.

### Finance & Accounting
Belgian PCMN chart of accounts (563 accounts), 29 Belgian VAT taxes, asset management, fiscal years, payment orders, banking mandates.

### Reporting
MIS Builder for P&L, Balance Sheet, and Cash Flow reports. XLSX export. Spreadsheet dashboards for Sales, HR, Expenses, Timesheets.

### Other
CRM, Sales, Purchase, Stock, Project, Calendar, Contracts.

## OCA Repositories (36 repos, all on 18.0)

payroll, hr, hr-attendance, hr-expense, hr-holidays, contract, timesheet, account-financial-tools, account-financial-reporting, account-invoicing, account-payment, account-analytic, account-budgeting, account-closing, bank-payment, mis-builder, operating-unit, l10n-usa, sale-workflow, purchase-workflow, stock-logistics-warehouse, stock-logistics-workflow, crm, project, calendar, reporting-engine, server-ux, server-tools, web, partner-contact, social, manufacture, knowledge, queue, connector

## Project Structure

```
odoo-self/
├── Dockerfile              # Odoo 18 + OCA repos
├── docker-compose.yml      # All services
├── config/
│   └── odoo.conf           # Odoo configuration
├── nginx/
│   └── odoo.conf           # Reverse proxy config
├── addons/                 # Custom addons (your modules go here)
├── enterprise/             # Enterprise addons (if licensed)
├── init-fresh.sh           # Full install script
├── .env.example            # Secret template
├── ARCHITECTURE.md         # System architecture & data flows
├── BEST_PRACTICES.md       # Startup management playbook
└── CLAUDE.md               # Development reference
```

## Custom Addons

Place custom modules in `addons/`. They are automatically included in the addon path.

## Configuration

All secrets are managed via `.env` (git-ignored). Copy `.env.example` and fill in:

| Variable | Purpose |
|----------|---------|
| `POSTGRES_PASSWORD` | Database password |
| `ODOO_ADMIN_PASSWD` | Odoo master password |
| `DST_ODOO_PASSWORD` | Odoo admin user password |

## Deployment

```bash
# On your server
git clone git@github.com:andr3wkh/odoo-self.git
cp .env.example .env
# Edit .env with production passwords
docker compose up -d
```

For SSL, update `nginx/odoo.conf` with your domain and certificates.

## Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) — Infrastructure, data flows, module map
- [BEST_PRACTICES.md](BEST_PRACTICES.md) — How to manage a startup with Odoo
- [CLAUDE.md](CLAUDE.md) — Development notes and reference

## License

Odoo Community Edition: LGPL-3.0. OCA addons: AGPL-3.0.
