# 🚗 Hyundai Next-Gen Dealership Management System (DMS)

> **Business Intelligence Dashboard** — Built with Python Flask, MySQL, Tailwind CSS & Chart.js

---

## 📁 Project Structure

```
sqlassign/
├── database/
│   ├── schema.sql                          # 12-table normalized MySQL schema
│   ├── seed_data.sql                       # Realistic seed data (2025)
│   ├── query1_invoice_booking_history.sql  # CTE + Window Function query
│   ├── query2_lead_conversion_report.sql   # Lead funnel analysis query
│   └── query3_annual_sales_report.sql      # Annual report with ROLLUP
├── static/
│   ├── index.html                          # Dashboard UI
│   ├── styles.css                          # Custom CSS
│   └── dashboard.js                        # Chart.js + API integration
├── app.py                                  # Flask backend (API server)
├── requirements.txt                        # Python dependencies
├── .env                                    # Database credentials (edit this)
└── README.md
```

---

## 🛠️ Setup Instructions

### 1. Create MySQL Database

```sql
CREATE DATABASE hyundai_dms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hyundai_dms;
```

Run the schema and seed data:
```bash
mysql -u root -p hyundai_dms < database/schema.sql
mysql -u root -p hyundai_dms < database/seed_data.sql
```

### 2. Configure Environment

Edit `.env` with your MySQL credentials:
```
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password_here
DB_NAME=hyundai_dms
```

### 3. Install Python Dependencies

```bash
pip install -r requirements.txt
```

### 4. Run the Application

```bash
python app.py
```

Open **http://localhost:5000** in your browser.

---

## 📊 Dashboard Sections

| Section | Description |
|---------|-------------|
| **Executive Dashboard** | KPI cards, monthly sales trend, model distribution |
| **Annual Sales Report** | Month-by-month bar charts, colour-wise pie, branch leaderboard |
| **Lead Conversion** | Stacked bar chart of enquiry funnel, branch-wise conversion rates |
| **Invoice Lookup** | Customer journey from enquiry → sale → payment ledger |

---

## 🗄️ Database Schema (12 Tables)

| # | Table | Purpose |
|---|-------|---------|
| 1 | `car_types` | Vehicle categories (SUV, Sedan, Hatchback, etc.) |
| 2 | `models` | Vehicle models (Creta, Venue, i20, etc.) |
| 3 | `variants` | Trim levels with pricing & specs |
| 4 | `colours` | Available colour palette with hex codes |
| 5 | `plants` | Manufacturing / assembly plants |
| 6 | `dealers` | Authorized dealership groups |
| 7 | `branches` | Physical showrooms / branches |
| 8 | `employees` | Sales & service staff |
| 9 | `customers` | Customer master data |
| 10 | `enquiries` | Lead / enquiry management |
| 11 | `sales` | Finalized vehicle sales with tax computation |
| 12 | `payments` | Payment transaction ledger |

---

## 🔍 Advanced SQL Queries

1. **Invoice / Booking History** — 3 CTEs tracking customer journey from enquiry → sale → payments with GST breakdown and running totals
2. **Lead Conversion Report** — 4 CTEs analyzing conversion funnels, stock availability, branch KPIs with RANK and cumulative window functions
3. **Executive Annual Sales Report** — 4 CTEs with month-by-month pivot, WITH ROLLUP grand totals, and branch revenue contribution percentages

Each query is **50+ lines** and uses **CTEs**, **Window Functions** (ROW_NUMBER, RANK, SUM OVER), and **Complex Joins**.

---

## 🎨 Branding

- **Primary**: Hyundai Dark Blue (`#002C5F`)
- **Accent**: Hyundai Cyan (`#00AAD2`)
- **Background**: Dark mode (`#030712`)
- **Typography**: Inter (Google Fonts)

---

© 2025 Hyundai Autoever — Developer Assignment
