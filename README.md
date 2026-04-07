# Odoo 18 Self-Hosted Startup Kit

A production-ready, self-hosted Odoo 18 Community Edition setup with 36 OCA addons — everything a startup needs for HR, Payroll, Finance, Leave, Appraisals, and more.

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

# 2. Configure
cp .env.example .env
nano .env  # set your passwords

# 3. Build and install (~10 min first time)
bash init-fresh.sh

# 4. Access
open http://localhost:8069
```

## What's Included (164 modules)

### HR & People
Employee management, attendance, contracts, expenses (with approval workflows), fleet, recruitment, skills, timesheets, work entries, presence tracking, remote work, org chart, appraisals.

### Leave Management
Holidays, public holidays, attendance integration, contract-based leave, leave allocation workflows.

### Payroll
OCA Payroll with multi-currency support, configurable salary structures, and full accounting integration.

### Finance & Accounting
Configurable chart of accounts, tax management, asset management, fiscal years, payment orders, banking mandates. Supports any country's localization.

### Reporting
MIS Builder for P&L, Balance Sheet, and Cash Flow reports. XLSX export. Spreadsheet dashboards for Sales, HR, Expenses, Timesheets.

### Other
CRM, Sales, Purchase, Stock, Project, Calendar, Contracts.

## OCA Repositories (36 repos, all on 18.0)

`payroll` `hr` `hr-attendance` `hr-expense` `hr-holidays` `contract` `timesheet` `account-financial-tools` `account-financial-reporting` `account-invoicing` `account-payment` `account-analytic` `account-budgeting` `account-closing` `bank-payment` `mis-builder` `operating-unit` `l10n-usa` `sale-workflow` `purchase-workflow` `stock-logistics-warehouse` `stock-logistics-workflow` `crm` `project` `calendar` `reporting-engine` `server-ux` `server-tools` `web` `partner-contact` `social` `manufacture` `knowledge` `queue` `connector`

## Project Structure

```
odoo-self/
├── Dockerfile              # Odoo 18 image + OCA repos
├── docker-compose.yml      # Full service stack
├── config/
│   └── odoo.conf           # Odoo configuration
├── nginx/
│   └── odoo.conf           # Reverse proxy config
├── addons/                 # Your custom modules go here
├── enterprise/             # Enterprise addons (if licensed)
├── init-fresh.sh           # Full install script
├── .env.example            # Secrets template
├── ARCHITECTURE.md         # System architecture & data flows
├── BEST_PRACTICES.md       # Startup management playbook
└── CLAUDE.md               # Development reference
```

## Configuration

All secrets are managed via `.env` (git-ignored). Copy `.env.example` and fill in:

| Variable | Purpose |
|----------|---------|
| `POSTGRES_PASSWORD` | Database password |
| `ODOO_ADMIN_PASSWD` | Odoo master password |
| `DST_ODOO_PASSWORD` | Odoo admin user password |

## Localization

The default setup uses US localization (`l10n_us`). To use a different country:

1. Install your country's localization module (e.g., `l10n_be`, `l10n_de`, `l10n_fr`)
2. Configure your chart of accounts, taxes, and fiscal positions
3. Set your company's country and currency in Settings

## Multi-Currency Payroll

The setup includes separate payroll journals for different currencies. Assign the correct journal on each employee's contract to route payroll entries to the right currency.

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
- [CLAUDE.md](CLAUDE.md) — Development reference

## License

MIT — see [LICENSE](LICENSE).

Odoo Community Edition: LGPL-3.0. OCA addons: AGPL-3.0.
