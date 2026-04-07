# Architecture — Odoo 18 Self-Hosted (Oblify bv)

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
hr.contract (wage=$1000, journal=PYUSD)
     ↓
hr.payslip (compute_sheet → salary rules → payslip lines)
     ↓
action_payslip_done → account.move (journal entry)
     ↓
┌─────────────────────────────────────────────────┐
│  620100 Salary Expense         DR  $1,150.00    │
│  440100 Salaries Payable       CR  $1,069.50    │
│  453100 Social Security Pay.   CR  $   80.50    │
└─────────────────────────────────────────────────┘
     ↓
MIS Builder → P&L Report (salary expense line)
            → Balance Sheet (liabilities)
            → Cash Flow (when paid)
```

### Multi-Currency Setup

```
Belgian employees (EUR)  →  Contract.journal_id = PYEUR  →  EUR journal entries
Egyptian employees (USD) →  Contract.journal_id = PYUSD  →  USD journal entries
                                                                    ↓
                                                          Auto-converted to EUR
                                                          at company currency rate
```

## Module Architecture

### Core Odoo 18 (built-in)
- `base`, `account`, `hr`, `crm`, `sale`, `purchase`, `stock`, `project`
- Belgian localization: `l10n_be` (PCMN chart of accounts, taxes)

### OCA Community Addons (36 repos, 18.0 branch)

```
/mnt/oca-addons/
├── hr/                    # HR extensions (appraisal, employee docs, etc.)
├── hr-attendance/         # Attendance extensions
├── hr-expense/           # Expense approvals, sequences
├── hr-holidays/          # Public holidays, leave extensions
├── payroll/              # OCA Payroll engine (replaces Enterprise payroll)
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
| Model | Table | Records | Purpose |
|-------|-------|---------|---------|
| `hr.employee` | hr_employee | 41 | Employee profiles |
| `hr.department` | hr_department | 14 | Org structure |
| `hr.job` | hr_job | 42 | Job positions |
| `hr.contract` | hr_contract | 1 | Employment contracts |
| `hr.leave` | hr_leave | 8 | Leave requests |
| `hr.leave.allocation` | hr_leave_allocation | 6 | Leave balances |
| `hr.leave.type` | hr_leave_type | 19 | Leave categories |
| `hr.expense` | hr_expense | 57 | Expense claims |
| `hr.appraisal` | hr_appraisal | 1 | Performance reviews |

### Payroll Domain
| Model | Table | Purpose |
|-------|-------|---------|
| `hr.payroll.structure` | hr_payroll_structure | Salary structure templates |
| `hr.salary.rule` | hr_salary_rule | Computation rules (BASIC, GROSS, NET) |
| `hr.salary.rule.category` | hr_salary_rule_category | Rule grouping (BASIC, ALW, DED, NET) |
| `hr.payslip` | hr_payslip | Monthly payslips |
| `hr.payslip.line` | hr_payslip_line | Computed salary lines |

### Finance Domain
| Model | Table | Records | Purpose |
|-------|-------|---------|---------|
| `account.account` | account_account | 563 | Chart of accounts (Belgian PCMN) |
| `account.tax` | account_tax | 31 | Belgian VAT taxes |
| `account.journal` | account_journal | 18 | Journals (sales, bank, payroll) |
| `account.move` | account_move | - | Journal entries (invoices, payroll) |
| `account.payment.term` | account_payment_term | 11 | Payment terms |
| `account.fiscal.position` | account_fiscal_position | 6 | Tax mapping rules |

### CRM / Sales
| Model | Table | Records | Purpose |
|-------|-------|---------|---------|
| `res.partner` | res_partner | 217+ | Customers & vendors |
| `product.template` | product_template | 29 | Service catalog |

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
- **Tax Balance**: VAT return preparation

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
- Admin user must be explicitly added to Appraisals groups
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
| Leave Allocations | Time Off > Managers > Allocations |
| Appraisal | Appraisals > Appraisals |
| MIS Reports | Accounting > Configuration > MIS Reports |
| Work Schedules | Employees > Configuration > Working Schedules |
| Departments | Employees > Configuration > Departments |
