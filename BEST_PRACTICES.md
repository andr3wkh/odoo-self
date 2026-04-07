# Best Practices — Managing a Startup with Odoo 18

## What This Setup Gives You

1. **Dockerized Odoo 18** with PostgreSQL 17, Redis, Nginx
2. **36 OCA repositories** (all on 18.0) covering HR, Payroll, Finance, Leave, Appraisals, Reporting
3. **Multi-currency payroll** — separate journals per currency for international teams
4. **Payroll → Finance integration** — salary rules mapped to accounting accounts, auto-generating journal entries
5. **MIS Builder** for P&L, Balance Sheet, and Cash Flow reports

---

## Startup Management Playbook

### 1. Initial Setup

```
Step 1: Install your country's localization
  Settings > Apps > Search "l10n_xx" > Install

Step 2: Configure company
  Settings > Companies > Update name, address, VAT, currency

Step 3: Set up chart of accounts
  Accounting > Configuration > Chart of Accounts
  (Country localization pre-loads these)

Step 4: Configure taxes
  Accounting > Configuration > Taxes
  (Country localization pre-loads common rates)

Step 5: Create departments
  Employees > Configuration > Departments

Step 6: Create job positions
  Employees > Configuration > Job Positions

Step 7: Set up leave types and allocations
  Time Off > Configuration > Leave Types
```

### 2. Onboarding a New Employee

```
Step 1: Create employee
  Employees > New
  Fill: name, department, job title, work email
  Set: manager, coach, work schedule, work location
  Add: personal info (birthday, nationality, emergency contact)

Step 2: Create contract
  Employee > Contracts tab > New
  Set: wage, salary structure, payroll journal
  Set: start date, end date, trial period
  Status: Running

Step 3: Allocate leave
  Time Off > Managers > Allocations > New
  Select employee, leave type, number of days
  Validate

Step 4: Set up appraisal (optional)
  Appraisals > New
  Select employee, set review date
  Write goals in the note field
  Status: Confirmed
```

### 3. Monthly Payroll Cycle

```
Step 1: Create payslips
  Payroll > Payslips > Create
  Select employee (auto-fills contract, structure, journal)
  Set period (e.g., 1st to 30th of month)
  Click "Compute Sheet"
  Review: Basic + Allowances - Deductions = Net

Step 2: Confirm
  Click "Done" → auto-creates journal entry
  Debit: Salary Expense account
  Credit: Salaries Payable + Deduction accounts

Step 3: Pay employees
  Accounting > Payments > Register payment against the payable

Step 4: Batch payroll (recommended)
  Payroll > Payslip Batches > New
  Add all employees, compute all, confirm all at once
```

### 4. Leave Management

```
Employee books leave:
  Time Off > New Request > Select type, dates > Submit

Manager approves:
  Time Off > Approvals > Review + Approve

HR monitors:
  Time Off > Managers > Overview (calendar view of all leave)

Annual allocation:
  Create allocation per employee at year start
  Or use accrual plans for gradual allocation
```

### 5. Performance Reviews (Appraisals)

```
HR creates appraisal:
  Appraisals > New > Select employee > Write goals in notes

Recommended goal structure (in the note field):
  - Goal 1: [Name] ([Weight]%) — measurable KPIs
  - Goal 2: [Name] ([Weight]%) — measurable KPIs
  - Rating scale: 1-5

Manager fills feedback:
  Manager feedback field with structured rating
  Comments on each goal, overall rating

Employee self-review:
  Employee feedback field, self-assessment on goals

Finalize:
  Status: Done → closes the appraisal cycle
```

### 6. Financial Reporting

```
P&L Report:
  Accounting > Reporting > MIS Reports > Create P&L template
  Map income accounts and expense accounts
  Result: Revenue - Expenses = Profit/Loss

Balance Sheet:
  Accounting > Reporting > MIS Reports > Create Balance Sheet template
  Map asset, liability, and equity accounts

Trial Balance:
  Accounting > Reporting > Trial Balance
  All account balances for any date range

Aged Receivables:
  Accounting > Reporting > Aged Partner Balance
  Outstanding invoices by age bucket
```

### 7. Expense Management

```
Employee submits:
  Expenses > New > Fill details > Attach receipt > Submit

Manager approves:
  Expenses > To Approve > Review + Approve

Finance processes:
  Expenses > To Post > Create journal entry > Pay
```

---

## Recommended Custom Modules

### High Priority

1. **Payroll Report PDF** — Custom QWeb PDF template for payslips, email delivery to employees
2. **Contract Renewal Workflow** — Automated reminders before expiry, renewal form with digital signature, PDF generation
3. **Structured Appraisal Goals** — Dedicated goal model (name, weight, KPI target, actual, rating), weighted score calculation
4. **Onboarding Checklist** — Automated task creation (IT setup, training, documents), Kanban tracking

### Medium Priority

5. **Multi-Company Support** — Inter-company transactions, consolidated reporting
6. **Leave Calendar Sync** — Sync approved leave to Google Calendar, team availability view
7. **KPI Dashboard** — Executive dashboard with real-time HR and financial KPIs

### Low Priority

8. **Country-Specific Payroll Rules** — Social security, tax brackets, benefits calculations for your jurisdiction
9. **External Integrations** — Sync with external tools (project management, time tracking, etc.)

---

## Operational Checklist

### Daily
- [ ] Check expense approvals queue
- [ ] Review leave requests

### Weekly
- [ ] Review recruitment pipeline
- [ ] Check project timesheets

### Monthly
- [ ] Run payroll batch
- [ ] Review P&L report
- [ ] Reconcile bank statements

### Quarterly
- [ ] Run appraisal cycle
- [ ] Review budget vs actual (MIS Builder)
- [ ] Update leave allocations if needed

### Annually
- [ ] Allocate annual leave for all employees
- [ ] Review and renew contracts
- [ ] Fiscal year closing
- [ ] Update tax configurations if rates change
- [ ] Review salary structures
