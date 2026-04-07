# Changelog

## v1.0.0 — 2026-04-07

### Initial Release

**Infrastructure:**
- Dockerized stack: Odoo 18 + PostgreSQL 17 + Redis 7 + Nginx
- All secrets managed via `.env` (git-ignored)
- Full install script (`init-fresh.sh`) — single command setup

**OCA Addons (36 repos, all 18.0 branch):**
- HR: payroll, attendance, expenses, holidays, contracts, timesheets, appraisals
- Finance: account-financial-tools, account-financial-reporting, account-analytic, account-budgeting, account-closing, mis-builder
- Sales/Purchase/Stock: sale-workflow, purchase-workflow, stock-logistics-warehouse, stock-logistics-workflow
- Other: crm, project, calendar, reporting-engine, server-ux, server-tools, web, partner-contact, social, manufacture, knowledge, queue, connector

**164 modules installed** covering:
- Full HR lifecycle (recruitment → onboarding → contracts → payroll → leave → appraisals)
- Multi-currency payroll with accounting integration
- MIS Builder for P&L, Balance Sheet, Cash Flow reports
- Expense management with tier approval workflows
- CRM, Sales, Purchase, Stock, Project management

**Documentation:**
- ARCHITECTURE.md — system architecture and data flows
- BEST_PRACTICES.md — startup management playbook
- CLAUDE.md — development reference
