# Architecture — Odoo 18 Self-Hosted Startup Kit

## Infrastructure Diagram

```
                    [Internet]
                        |
                   [Nginx :80]
                        |
                  [Odoo 18 :8069]
                   /          \
          [PostgreSQL 17]   [Redis 7]
            :5432             :6379
         (data store)    (session cache)
```

## Docker Services

| Service | Image | Port | Role |
|---------|-------|------|------|
| `odoo-server` | Custom (odoo:18 + 36 OCA repos) | 8069, 8072 | Application server |
| `odoo-db` | postgres:17 | 5432 | Primary database |
| `odoo-redis` | redis:7-alpine | 6379 | Session store |
| `odoo-nginx` | nginx:alpine | 80 | Reverse proxy + SSL termination |

## Data Flow

### Employee Lifecycle

```
Recruitment → Onboarding → Contract → Payroll → Leave → Appraisal
                 ↓             ↓          ↓        ↓         ↓
           hr.employee    hr.contract  hr.payslip  hr.leave  hr.appraisal
                               ↓          ↓
                          Work Entries  Journal Entry
                                          ↓
                                   account.move → P&L / Balance Sheet
```

### Payroll → Finance Flow

```
hr.contract (wage, journal, structure)
     ↓
hr.payslip (compute_sheet → salary rules → payslip lines)
     ↓
action_payslip_done → account.move (journal entry)
     ↓
┌─────────────────────────────────────────────────┐
│  6xxxxx Salary Expense         DR  (gross)      │
│  4xxxxx Salaries Payable       CR  (net pay)    │
│  4xxxxx Social Security Pay.   CR  (deductions) │
└─────────────────────────────────────────────────┘
     ↓
MIS Builder → P&L Report (salary expense line)
            → Balance Sheet (liabilities)
            → Cash Flow (when paid)
```

### Multi-Currency Setup

```
Currency A employees  →  Contract.journal_id = PY_A  →  Currency A entries
Currency B employees  →  Contract.journal_id = PY_B  →  Currency B entries
                                                              ↓
                                                    Auto-converted to company
                                                    currency at current rate
```

## Module Architecture

### Core Odoo 18 (built-in)
- `base`, `account`, `hr`, `crm`, `sale`, `purchase`, `stock`, `project`
- Country localizations installed separately (e.g., `l10n_us`, `l10n_be`, `l10n_de`)

### OCA Community Addons (36 repos, 18.0 branch)

```
/mnt/oca-addons/
├── hr/                    # HR extensions (appraisal, employee docs, etc.)
├── hr-attendance/         # Attendance extensions
├── hr-expense/           # Expense approvals, sequences
├── hr-holidays/          # Public holidays, leave extensions
├── payroll/              # OCA Payroll engine
├── contract/             # Employee contract management
├── timesheet/            # Timesheet extensions
├── account-financial-tools/      # Asset mgmt, fiscal year, tax balance
├── account-financial-reporting/  # Trial balance, general ledger, aged reports
├── account-analytic/     # Cost center analysis
├── account-budgeting/    # Budget management
├── account-closing/      # Period closing
├── mis-builder/          # P&L, Balance Sheet, Cash Flow report builder
├── bank-payment/         # SEPA, banking mandates
├── reporting-engine/     # XLSX export, report templates
├── server-ux/           # Date ranges, tier validation
├── server-tools/        # Cron, audit log, utilities
├── web/                 # Backend UI enhancements
├── calendar/            # Public holiday calendar
├── ... (17 more repos)
└── connector/           # Integration framework
```

### Custom Addons
```
/mnt/extra-addons/       # Your custom modules go here
├── (empty — ready for custom development)
```

## Database Schema (Key Models)

### HR Domain
| Model | Purpose |
|-------|---------|
| `hr.employee` | Employee profiles |
| `hr.department` | Org structure |
| `hr.job` | Job positions |
| `hr.contract` | Employment contracts |
| `hr.leave` | Leave requests |
| `hr.leave.allocation` | Leave balances |
| `hr.leave.type` | Leave categories |
| `hr.expense` | Expense claims |
| `hr.appraisal` | Performance reviews |

### Payroll Domain
| Model | Purpose |
|-------|---------|
| `hr.payroll.structure` | Salary structure templates |
| `hr.salary.rule` | Computation rules (BASIC, GROSS, NET) |
| `hr.salary.rule.category` | Rule grouping (BASIC, ALW, DED, NET) |
| `hr.payslip` | Monthly payslips |
| `hr.payslip.line` | Computed salary lines |

### Finance Domain
| Model | Purpose |
|-------|---------|
| `account.account` | Chart of accounts |
| `account.tax` | Tax configuration |
| `account.journal` | Journals (sales, bank, payroll) |
| `account.move` | Journal entries (invoices, payroll) |
| `account.payment.term` | Payment terms |
| `account.fiscal.position` | Tax mapping rules |

### CRM / Sales
| Model | Purpose |
|-------|---------|
| `res.partner` | Customers & vendors |
| `product.template` | Product / service catalog |

## Reporting Stack

### MIS Builder (P&L, Balance Sheet, Cash Flow)
- **Engine**: `mis_builder` — template-based financial reporting
- **Budget**: `mis_builder_budget` — budget vs actual comparisons
- **Cash Flow**: `mis_builder_cash_flow` — cash movement analysis
- Configure templates at: Accounting > Configuration > MIS Reports

### OCA Financial Reports
- **Trial Balance**: Account balances for any period
- **General Ledger**: All transactions per account
- **Aged Partner Balance**: Outstanding receivables/payables
- **Tax Balance**: VAT/tax return preparation

### Spreadsheet Dashboards
- Pre-built dashboards for Sales, HR, Expenses, Timesheets
- Access at: Dashboards menu

## Security Model

### Key Groups
| Group | Access |
|-------|--------|
| HR User | View own + team employee data |
| HR Officer | Manage all employees, contracts, payroll |
| Appraisals User | View appraisals menu |
| Appraisals HR Officer | Manage all appraisals |
| Accounting Manager | Full accounting access |

### Access Notes
- Admin must be explicitly added to Appraisals groups (OCA module)
- Leave approvers are set per employee (`leave_manager_id`)
- Expense approvers are set per employee (`expense_manager_id`)

## Configuration Locations

| Setting | Where |
|---------|-------|
| Company info | Settings > General Settings > Companies |
| Chart of Accounts | Accounting > Configuration > Chart of Accounts |
| Taxes | Accounting > Configuration > Taxes |
| Journals | Accounting > Configuration > Journals |
| Payroll Structure | Payroll > Configuration > Structures |
| Salary Rules | Payroll > Configuration > Salary Rules |
| Leave Types | Time Off > Configuration > Leave Types |
| Allocations | Time Off > Managers > Allocations |
| Appraisals | Appraisals > Appraisals |
| MIS Reports | Accounting > Configuration > MIS Reports |
| Work Schedules | Employees > Configuration > Working Schedules |
| Departments | Employees > Configuration > Departments |
