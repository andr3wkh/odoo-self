FROM odoo:18

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /mnt/oca-addons

# =====================================================
# OCA Repositories — all pinned to 18.0 branch
# =====================================================

# ── HR ──
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/hr.git /mnt/oca-addons/hr
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/hr-attendance.git /mnt/oca-addons/hr-attendance
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/hr-expense.git /mnt/oca-addons/hr-expense
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/hr-holidays.git /mnt/oca-addons/hr-holidays
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/payroll.git /mnt/oca-addons/payroll
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/contract.git /mnt/oca-addons/contract
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/timesheet.git /mnt/oca-addons/timesheet

# ── Finance / Accounting ──
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/account-financial-tools.git /mnt/oca-addons/account-financial-tools
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/account-financial-reporting.git /mnt/oca-addons/account-financial-reporting
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/account-invoicing.git /mnt/oca-addons/account-invoicing
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/account-payment.git /mnt/oca-addons/account-payment
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/account-analytic.git /mnt/oca-addons/account-analytic
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/account-budgeting.git /mnt/oca-addons/account-budgeting
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/account-closing.git /mnt/oca-addons/account-closing
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/bank-payment.git /mnt/oca-addons/bank-payment
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/mis-builder.git /mnt/oca-addons/mis-builder
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/operating-unit.git /mnt/oca-addons/operating-unit

# ── US Localization ──
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/l10n-usa.git /mnt/oca-addons/l10n-usa

# ── Sales / Purchase / Stock ──
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/sale-workflow.git /mnt/oca-addons/sale-workflow
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/purchase-workflow.git /mnt/oca-addons/purchase-workflow
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/stock-logistics-warehouse.git /mnt/oca-addons/stock-logistics-warehouse
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/stock-logistics-workflow.git /mnt/oca-addons/stock-logistics-workflow

# ── CRM / Project / Calendar ──
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/crm.git /mnt/oca-addons/crm
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/project.git /mnt/oca-addons/project
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/calendar.git /mnt/oca-addons/calendar

# ── Reporting / Server / Web ──
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/reporting-engine.git /mnt/oca-addons/reporting-engine
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/server-ux.git /mnt/oca-addons/server-ux
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/server-tools.git /mnt/oca-addons/server-tools
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/web.git /mnt/oca-addons/web

# ── Other ──
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/partner-contact.git /mnt/oca-addons/partner-contact
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/social.git /mnt/oca-addons/social
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/manufacture.git /mnt/oca-addons/manufacture
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/knowledge.git /mnt/oca-addons/knowledge
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/queue.git /mnt/oca-addons/queue
RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/connector.git /mnt/oca-addons/connector

# =====================================================
# Python dependencies from all OCA modules
# =====================================================
RUN find /mnt/oca-addons -name 'requirements.txt' -exec pip3 install --break-system-packages -r {} \; 2>/dev/null || true
RUN pip3 install --break-system-packages \
    redis num2words phonenumbers openupgradelib xlsxwriter \
    python-stdnum cryptography 2>/dev/null || true

USER odoo
