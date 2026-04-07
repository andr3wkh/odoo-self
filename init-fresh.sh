#!/bin/bash
set -e

# =====================================================
# Odoo 18 — Fresh Install Script
# Drops old DB, rebuilds containers, installs modules
# =====================================================

echo "============================================="
echo "  Odoo 18 Fresh Install — PostgreSQL 17"
echo "============================================="

# Load env vars
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi
DB_USER="${POSTGRES_USER:-odoo}"
DB_NAME="${ODOO_DB_NAME:-odoo18}"
[ "$DB_NAME" = "False" ] && DB_NAME="odoo18"

# Step 1: Tear down everything (containers + volumes)
echo ""
echo "[1/5] Stopping containers and removing volumes..."
docker compose down -v 2>/dev/null || true

# Step 2: Rebuild the Odoo image (clones all OCA repos)
echo ""
echo "[2/5] Building Odoo image (this clones all OCA repos — may take a few minutes)..."
docker compose build --no-cache odoo

# Step 3: Start DB + Redis first, wait for health
echo ""
echo "[3/5] Starting PostgreSQL 17 and Redis..."
docker compose up -d db redis
echo "Waiting for database to be ready..."
sleep 5
until docker compose exec db pg_isready -U "$DB_USER" > /dev/null 2>&1; do
    echo "  ...waiting for PostgreSQL..."
    sleep 3
done
echo "PostgreSQL 17 is ready."

# Step 4: Create the database
echo ""
echo "[4/5] Creating fresh ${DB_NAME} database..."
docker compose exec db psql -U "$DB_USER" -d postgres -c "DROP DATABASE IF EXISTS ${DB_NAME};" 2>/dev/null || true
docker compose exec db psql -U "$DB_USER" -d postgres -c "CREATE DATABASE ${DB_NAME} OWNER ${DB_USER} ENCODING 'UTF8' LC_COLLATE 'en_US.utf8' LC_CTYPE 'en_US.utf8' TEMPLATE template0;"
echo "Database ${DB_NAME} created."

# Step 5: Initialize Odoo with all modules
echo ""
echo "[5/5] Initializing Odoo with all modules (this will take several minutes)..."

# ── Module list ──
# Grouped by function for clarity; Odoo resolves dependencies automatically.

HR_MODULES="hr,hr_attendance,hr_contract,hr_expense,hr_expense_sequence,hr_expense_tier_validation,hr_fleet,hr_recruitment,hr_skills,hr_timesheet,hr_work_entry,hr_work_entry_contract,hr_presence,hr_homeworking,hr_org_chart,hr_department_code,hr_employee_document,hr_employee_firstname,hr_employee_id,hr_employee_ssn,hr_employee_relative,hr_hourly_cost,hr_calendar"

LEAVE_MODULES="hr_holidays,hr_holidays_public,hr_holidays_attendance,hr_holidays_contract"

APPRAISAL_MODULES="hr_appraisal_oca"

PAYROLL_MODULES="payroll,payroll_account"

CONTRACT_MODULES="contract"

FINANCE_MODULES="account,account_asset_management,account_financial_report,account_tax_balance,account_fiscal_year,account_payment_order,account_payment_mode,account_payment_partner,account_payment_purchase,account_payment_sale"

REPORTING_MODULES="mis_builder,mis_builder_budget,mis_builder_cash_flow,report_xlsx,report_xlsx_helper"

ANALYTIC_MODULES="analytic"

BANK_MODULES="account_banking_mandate"

SALES_MODULES="sale_management,sale_crm,sale_stock,sale_timesheet,sale_expense,sale_project"

PURCHASE_MODULES="purchase,purchase_stock"

STOCK_MODULES="stock,stock_account"

PROJECT_MODULES="project,project_timesheet_holidays,project_hr_expense"

CRM_MODULES="crm,contacts"

OTHER_MODULES="calendar,calendar_public_holiday,fleet,spreadsheet_dashboard,spreadsheet_dashboard_account,spreadsheet_dashboard_hr_expense,spreadsheet_dashboard_hr_timesheet,spreadsheet_dashboard_sale,board,date_range"

SERVER_MODULES="base_import_module"

ALL_MODULES="${HR_MODULES},${LEAVE_MODULES},${APPRAISAL_MODULES},${PAYROLL_MODULES},${CONTRACT_MODULES},${FINANCE_MODULES},${REPORTING_MODULES},${ANALYTIC_MODULES},${BANK_MODULES},${SALES_MODULES},${PURCHASE_MODULES},${STOCK_MODULES},${PROJECT_MODULES},${CRM_MODULES},${OTHER_MODULES},${SERVER_MODULES}"

docker compose run --rm odoo odoo \
    --config=/etc/odoo/odoo.conf \
    --database="${DB_NAME}" \
    --init="${ALL_MODULES}" \
    --stop-after-init \
    --without-demo=all \
    --load-language=en_US

echo ""
echo "============================================="
echo "  Installation complete!"
echo "============================================="
echo ""
echo "Starting all services..."
docker compose up -d

echo ""
echo "Odoo 18 is starting up at:"
echo "  - Direct:  http://localhost:8069"
echo "  - Nginx:   http://localhost"
echo ""
echo "Installed module groups:"
echo "  - HR: attendance, contracts, expenses, fleet, recruitment, skills, timesheets, work entries, presence, remote work"
echo "  - Leave: holidays, public holidays"
echo "  - Appraisals: OCA appraisal module"
echo "  - Payroll: payroll + payroll accounting"
echo "  - Finance: accounting, assets, fiscal years, tax balance, payment orders"
echo "  - Reporting: MIS Builder (P&L, Balance Sheet, Cash Flow), XLSX reports"
echo "  - Budget: MIS Builder Budget"
echo "  - Sales/Purchase/Stock/CRM/Project"
echo ""
echo "Next steps:"
echo "  1. Go to http://localhost:8069 and log in"
echo "  2. Settings > Accounting > Install a Chart of Accounts (US GAAP or your preference)"
echo "  3. Accounting > Configuration > MIS Reports > Create P&L and Balance Sheet templates"
echo "  4. HR > Configuration > Set up departments, job positions, leave types"
echo ""
