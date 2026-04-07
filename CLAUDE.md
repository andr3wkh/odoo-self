# Odoo 18 Self-Hosted — Oblify bv

## Project Overview

Self-hosted Odoo 18 (Community Edition) with OCA addons for **Oblify bv**, a Belgian startup (Antwerpen). Migrated from the Odoo.com SaaS instance at `meezy.odoo.com`.

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

- **Odoo Admin**: admin / (see .env `DST_ODOO_PASSWORD`)
- **DB**: odoo / (see .env `POSTGRES_PASSWORD`)
- **Admin Master Password**: (see .env `ODOO_ADMIN_PASSWD`)
- All secrets are in `.env` (git-ignored). Copy `.env.example` to `.env` and fill in.

## Key Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | All services (pg17, redis, odoo, nginx) |
| `Dockerfile` | Odoo image + 36 OCA repos cloned at build |
| `config/odoo.conf` | Odoo config with all addon paths |
| `init-fresh.sh` | Nuclear option — drops DB, rebuilds everything |
| `migrate_data.py` | Migrates employees from CSV exports |
| `migrate_company.py` | Migrates company setup from meezy.odoo.com |
| `setup_andrew.py` | Full onboarding example (Andrew Khalil) |

## Company Info

- **Name**: Oblify bv
- **Country**: Belgium (BE)
- **VAT**: BE0778399363
- **Currency**: EUR (primary), USD and EGP active
- **Chart of Accounts**: Belgian PCMN (563 accounts)
- **Fiscal Positions**: National, Intra-EU, EU B2C, Extra-EU

## Installed Module Groups (164 total)

### HR & People
`hr`, `hr_attendance`, `hr_contract`, `hr_expense`, `hr_expense_sequence`, `hr_expense_tier_validation`, `hr_fleet`, `hr_recruitment`, `hr_skills`, `hr_timesheet`, `hr_work_entry`, `hr_presence`, `hr_homeworking`, `hr_org_chart`, `hr_department_code`, `hr_employee_document`, `hr_employee_firstname`, `hr_employee_id`, `hr_employee_ssn`, `hr_employee_relative`, `hr_appraisal_oca`

### Leave Management
`hr_holidays`, `hr_holidays_public`, `hr_holidays_attendance`, `hr_holidays_contract`, `calendar_public_holiday`

### Payroll
`payroll` (OCA), `payroll_account` — multi-currency (USD/EUR journals)

### Finance
`account`, `account_asset_management`, `account_financial_report`, `account_tax_balance`, `account_fiscal_year`, `account_payment_order`, `mis_builder`, `mis_builder_budget`, `mis_builder_cash_flow`

### Other
CRM, Sales, Purchase, Stock, Project, Spreadsheet Dashboards, Contracts

## OCA Repositories (36 total, all 18.0)

payroll, hr, hr-attendance, hr-expense, hr-holidays, contract, timesheet, account-financial-tools, account-financial-reporting, account-invoicing, account-payment, account-analytic, account-budgeting, account-closing, bank-payment, mis-builder, operating-unit, l10n-usa, sale-workflow, purchase-workflow, stock-logistics-warehouse, stock-logistics-workflow, crm, project, calendar, reporting-engine, server-ux, server-tools, web, partner-contact, social, manufacture, knowledge, queue, connector

## Payroll Structure

Structure: **Base Salary Structure** (code: BASE)

| Rule | Code | Type | Formula |
|------|------|------|---------|
| Basic Salary | BASIC | Code | `contract.wage` |
| Housing Allowance | HRA | % | 10% of wage |
| Transport Allowance | TA | Fix | 50 |
| Gross Salary | GROSS | Code | `categories.BASIC + categories.ALW` |
| Social Security | SSC | % | -7% of GROSS |
| Net Salary | NET | Code | `categories.GROSS + categories.DED` |

Accounts: Expense=620100, Payable=440100, SS Payable=453100

## Multi-Currency Payroll

- **PYUSD** journal: For USD-paid employees (e.g., Egypt team)
- **PYEUR** journal: For EUR-paid employees (e.g., Belgium team)
- Set `journal_id` on the employee's contract to route to correct journal

## Development Notes

- OCA payroll uses `BrowsableObject` — access categories via dot notation: `categories.BASIC`, not `categories['BASIC']`
- Source Odoo (meezy.odoo.com) runs 19.0 SaaS — some fields differ from 18.0 (`mobile` removed from `res.partner`, `deprecated`/`company_id` removed from `account.account`)
- Leave type `requires_allocation` is a selection field in 18.0 (`yes`/`no`), was boolean in older versions
- Appraisal states: `1_new`, `2_pending`, `3_done` (OCA module)
