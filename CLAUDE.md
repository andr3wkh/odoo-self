# Odoo 18 Self-Hosted Startup Kit

## Project Overview

Self-hosted Odoo 18 (Community Edition) with OCA addons — a complete startup ERP covering HR, Payroll, Finance, Leave, Appraisals, CRM, Sales, Purchase, and Stock.

## Quick Start

```bash
# Full fresh install (drops DB, rebuilds, installs 164 modules)
bash init-fresh.sh

# Start services
docker compose up -d

# Access
http://localhost:8069   # Direct
http://localhost         # Via Nginx
```

## Stack

- **Odoo 18** Community Edition (Docker)
- **PostgreSQL 17** (container: odoo-db, port 5432)
- **Redis 7** Alpine (session store, port 6379)
- **Nginx** Alpine (reverse proxy, port 80)
- All OCA repos pinned to **18.0 branch**

## Credentials

All secrets are in `.env` (git-ignored). See `.env.example` for the template.

## Key Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | All services (pg17, redis, odoo, nginx) |
| `Dockerfile` | Odoo image + 36 OCA repos cloned at build |
| `config/odoo.conf` | Odoo config with all addon paths |
| `init-fresh.sh` | Full reset — drops DB, rebuilds everything |
| `addons/` | Your custom modules go here |

## Installed Module Groups (164 total)

### HR & People
`hr`, `hr_attendance`, `hr_contract`, `hr_expense`, `hr_expense_sequence`, `hr_expense_tier_validation`, `hr_fleet`, `hr_recruitment`, `hr_skills`, `hr_timesheet`, `hr_work_entry`, `hr_presence`, `hr_homeworking`, `hr_org_chart`, `hr_department_code`, `hr_employee_document`, `hr_employee_firstname`, `hr_employee_id`, `hr_employee_ssn`, `hr_employee_relative`, `hr_appraisal_oca`

### Leave Management
`hr_holidays`, `hr_holidays_public`, `hr_holidays_attendance`, `hr_holidays_contract`, `calendar_public_holiday`

### Payroll
`payroll` (OCA), `payroll_account` — supports multi-currency journals

### Finance
`account`, `account_asset_management`, `account_financial_report`, `account_tax_balance`, `account_fiscal_year`, `account_payment_order`, `mis_builder`, `mis_builder_budget`, `mis_builder_cash_flow`

### Other
CRM, Sales, Purchase, Stock, Project, Spreadsheet Dashboards, Contracts

## OCA Repositories (36 total, all 18.0)

payroll, hr, hr-attendance, hr-expense, hr-holidays, contract, timesheet, account-financial-tools, account-financial-reporting, account-invoicing, account-payment, account-analytic, account-budgeting, account-closing, bank-payment, mis-builder, operating-unit, l10n-usa, sale-workflow, purchase-workflow, stock-logistics-warehouse, stock-logistics-workflow, crm, project, calendar, reporting-engine, server-ux, server-tools, web, partner-contact, social, manufacture, knowledge, queue, connector

## Payroll Structure (Example)

Structure: **Base Salary Structure** (code: BASE)

| Rule | Code | Type | Formula |
|------|------|------|---------|
| Basic Salary | BASIC | Code | `contract.wage` |
| Housing Allowance | HRA | % | 10% of wage |
| Transport Allowance | TA | Fix | 50 |
| Gross Salary | GROSS | Code | `categories.BASIC + categories.ALW` |
| Social Security | SSC | % | -7% of GROSS |
| Net Salary | NET | Code | `categories.GROSS + categories.DED` |

Customize these rules to match your country's requirements.

## Multi-Currency Payroll

Create separate payroll journals for each currency (e.g., `PYUSD`, `PYEUR`). Set `journal_id` on the employee's contract to route payroll to the correct journal.

## Development Notes

- OCA payroll uses `BrowsableObject` — access categories via dot notation: `categories.BASIC`, not `categories['BASIC']`
- Leave type `requires_allocation` is a selection field (`yes`/`no`), not boolean
- Appraisal states (OCA): `1_new`, `2_pending`, `3_done`
- Place custom modules in `addons/` — they are auto-loaded via the addon path in `odoo.conf`

## Localization

Default: US (`l10n_us`). To switch countries:
1. Install your localization module via Odoo Apps (e.g., `l10n_be`, `l10n_de`, `l10n_fr`)
2. Configure chart of accounts, taxes, fiscal positions
3. Update company country and currency in Settings
