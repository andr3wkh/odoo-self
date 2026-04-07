# Best Practices — Managing a Startup with Odoo 18

## How We Built This

### What we did
1. **Fresh Odoo 18** on Docker with PostgreSQL 17, Redis, Nginx
2. **36 OCA repositories** (all on 18.0 branch) covering HR, Payroll, Finance, Leave, Appraisals, Reporting
3. **Belgian localization** (l10n_be) for chart of accounts, taxes, fiscal positions
4. **Multi-currency payroll** — USD and EUR journals for international teams
5. **Full data migration** from Odoo.com SaaS (meezy.odoo.com) via XML-RPC
6. **Employee migration** from CSV exports (40 employees, departments, jobs, skills, expenses)
7. **Payroll → Finance integration** — salary rules mapped to accounting accounts, auto-generating journal entries

### What we configured
- 563 chart of accounts (Belgian PCMN)
- 29 Belgian VAT taxes
- 18 journals (4 sales, 4 bank, 2 payroll, 4 general, 1 purchase)
- 6 fiscal positions
- Payroll structure with 6 salary rules (Basic, HRA, Transport, Gross, SS, Net)
- 19 leave types (Annual, Sick, Unpaid, Maternity, etc.)
- Appraisal system with goal-based reviews

---

## Startup Management Playbook

### 1. Onboarding a New Employee

```
Step 1: Employees > New
  - Fill: name, department, job title, work email
  - Set: manager (parent_id), coach, work schedule, work location
  - Add: personal info (birthday, nationality, emergency contact)

Step 2: Create Contract
  - Employees > Employee > Contracts tab > New
  - Set: wage, structure (Base Salary Structure), journal (PYUSD or PYEUR)
  - Set: start date, end date, trial period
  - Status: Running

Step 3: Allocate Leave
  - Time Off > Managers > Allocations > New
  - Select employee, leave type (Annual), days (21)
  - Validate

Step 4: Set Up Appraisal
  - Appraisals > New
  - Select employee, set review date
  - Write goals in the note field
  - Status: Confirmed (sends notification)
```

### 2. Monthly Payroll Cycle

```
Step 1: Payroll > Payslips > Create
  - Select employee (auto-fills contract, structure, journal)
  - Set period (e.g., 2026-04-01 to 2026-04-30)
  - Click "Compute Sheet"
  - Review: Basic + Allowances - Deductions = Net

Step 2: Confirm payslip
  - Click "Done" → auto-creates journal entry
  - Debit: Salary Expense (620100)
  - Credit: Salaries Payable (440100) + SS Payable (453100)

Step 3: Pay employee
  - Accounting > Payments > Register payment against the payable

Step 4: Batch payroll (optional)
  - Payroll > Payslip Batches > New
  - Add all employees, compute all, confirm all at once
```

### 3. Leave Management

```
Employee books leave:
  Time Off > New Request > Select type, dates > Submit

Manager approves:
  Time Off > Approvals > Review + Approve

HR monitors:
  Time Off > Managers > Overview (calendar view of all leave)

Annual allocation:
  - Create 21-day allocation per employee at year start
  - Or use accrual plans for gradual allocation
```

### 4. Performance Reviews (Appraisals)

```
HR creates appraisal:
  Appraisals > New > Select employee > Write goals in notes

Goal-setting approach (we use structured HTML in the note field):
  - Goal 1: Service Level (50% weight) — measurable KPIs
  - Goal 2: Quality (50% weight) — measurable KPIs
  - Rating scale: 1-5

Manager fills feedback:
  - Manager feedback field with structured rating form
  - Comments on each goal
  - Overall rating

Employee self-review:
  - Employee feedback field
  - Self-assessment on goals

Finalize:
  - Status: Done → triggers next appraisal date
```

### 5. Financial Reporting

```
P&L Report:
  Accounting > Reporting > MIS Reports > Create P&L template
  - Income accounts (700xxx)
  - Expense accounts (600xxx-620xxx including payroll)
  - Result: Revenue - Expenses = Profit/Loss

Balance Sheet:
  Accounting > Reporting > MIS Reports > Create Balance Sheet template
  - Assets (2xxxxx-4xxxxx)
  - Liabilities (4xxxxx including Salaries Payable)
  - Equity (1xxxxx)

Trial Balance:
  Accounting > Reporting > Trial Balance
  - All account balances for any date range

Aged Receivables:
  Accounting > Reporting > Aged Partner Balance
  - Outstanding invoices by age bucket
```

### 6. Expense Management

```
Employee submits:
  Expenses > New > Fill details > Attach receipt > Submit

Manager approves:
  Expenses > To Approve > Review + Approve

Finance processes:
  Expenses > To Post > Create journal entry > Pay
```

---

## What to Add Custom

### High Priority (build as custom addons in `/mnt/extra-addons/`)

1. **Payroll Report PDF** (`oblify_payroll_report`)
   - Custom QWeb PDF template for payslips
   - Employee can download their payslip as PDF
   - Email payslip PDF to employee monthly

2. **Contract Renewal Workflow** (`oblify_contract_renewal`)
   - Automated email 30 days before contract expiry
   - Renewal form with digital signature
   - PDF contract generation from template
   - Status tracking: Draft > Sent > Signed > Active

3. **Appraisal Goals Module** (`oblify_appraisal_goals`)
   - Dedicated goal model (not just HTML in notes)
   - Fields: goal name, weight, KPI target, KPI actual, rating
   - Auto-calculate weighted score
   - Manager rating form as a separate wizard

4. **KPI Dashboard Integration** (`oblify_kpi_bridge`)
   - Bridge to your existing kpi-sys (port 8080)
   - Sync employee performance data
   - Sync financial KPIs from MIS Builder

### Medium Priority

5. **Multi-Company Support** (`oblify_multi_company`)
   - If Oblify expands to multiple entities
   - Inter-company transactions
   - Consolidated reporting

6. **Onboarding Checklist** (`oblify_onboarding`)
   - Automated onboarding tasks (IT setup, training, documents)
   - Kanban board for HR to track progress
   - Employee self-service portal

7. **Leave Calendar Sync** (`oblify_leave_sync`)
   - Sync approved leave to Google Calendar
   - Team availability view

### Low Priority

8. **Custom Belgian Payroll Rules** (`oblify_be_payroll`)
   - Belgian social security calculations
   - Meal voucher deductions
   - Company car benefit-in-kind
   - 13th month salary

9. **Notion Integration** (`oblify_notion_sync`)
   - Two-way sync with Notion databases
   - Task sync, employee data sync

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
- [ ] Submit VAT return data

### Quarterly
- [ ] Run appraisal cycle
- [ ] Review budget vs actual (MIS Builder)
- [ ] Update leave allocations if needed

### Annually
- [ ] Allocate annual leave (21 days per employee)
- [ ] Review and renew contracts
- [ ] Fiscal year closing
- [ ] Update tax configurations if rates change
- [ ] Review salary structures

---

## Key URLs

| Service | URL |
|---------|-----|
| Odoo (direct) | http://localhost:8069 |
| Odoo (nginx) | http://localhost |
| PostgreSQL | localhost:5432 |
| Redis | localhost:6379 |
| KPI Dashboard | http://localhost:8080 |
