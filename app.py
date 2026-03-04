"""
Hyundai Next-Gen Dealership Management System (DMS)
Flask Backend — API Endpoints for BI Dashboard
"""

import os
import json
import decimal
import datetime
from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
from dotenv import load_dotenv
import mysql.connector
from mysql.connector import Error

load_dotenv()

app = Flask(__name__, static_folder='static', static_url_path='')
CORS(app)


# ─── JSON encoder for Decimal & Date types ───────────────────────────────────
class CustomEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            return float(obj)
        if isinstance(obj, (datetime.date, datetime.datetime)):
            return obj.isoformat()
        return super().default(obj)

app.json_encoder = CustomEncoder


# ─── Database connection helper ──────────────────────────────────────────────
def get_db_connection():
    """Create and return a MySQL connection using .env credentials."""
    try:
        conn = mysql.connector.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            port=int(os.getenv('DB_PORT', 3306)),
            user=os.getenv('DB_USER', 'root'),
            password=os.getenv('DB_PASSWORD', ''),
            database=os.getenv('DB_NAME', 'hyundai_dms'),
            charset='utf8mb4'
        )
        return conn
    except Error as e:
        print(f"Database connection error: {e}")
        return None


def execute_query(query, params=None):
    """Execute a query and return results as list of dicts."""
    conn = get_db_connection()
    if not conn:
        return None, "Database connection failed"
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params or ())
        rows = cursor.fetchall()
        # Convert Decimal/date values for JSON serialization
        cleaned = []
        for row in rows:
            clean_row = {}
            for k, v in row.items():
                if isinstance(v, decimal.Decimal):
                    clean_row[k] = float(v)
                elif isinstance(v, (datetime.date, datetime.datetime)):
                    clean_row[k] = v.isoformat()
                else:
                    clean_row[k] = v
            cleaned.append(clean_row)
        return cleaned, None
    except Error as e:
        return None, str(e)
    finally:
        cursor.close()
        conn.close()


# ═══════════════════════════════════════════════════════════════════════════════
# SERVE FRONTEND
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/')
def serve_index():
    return send_from_directory('static', 'index.html')


# ═══════════════════════════════════════════════════════════════════════════════
# API : Dashboard KPI Summary
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/dashboard/summary', methods=['GET'])
def dashboard_summary():
    """High-level KPIs for the dashboard header."""
    query = """
        SELECT
            (SELECT COUNT(*) FROM sales WHERE delivery_status <> 'Cancelled' AND YEAR(sale_date) = 2025) AS total_sales,
            (SELECT COALESCE(SUM(total_on_road), 0) FROM sales WHERE delivery_status <> 'Cancelled' AND YEAR(sale_date) = 2025) AS total_revenue,
            (SELECT COUNT(*) FROM enquiries WHERE YEAR(enquiry_date) = 2025) AS total_enquiries,
            (SELECT COUNT(*) FROM enquiries WHERE status = 'Converted' AND YEAR(enquiry_date) = 2025) AS converted_enquiries,
            (SELECT COUNT(*) FROM customers) AS total_customers,
            (SELECT COUNT(*) FROM branches WHERE is_active = 1) AS active_branches
    """
    data, err = execute_query(query)
    if err:
        return jsonify({'error': err}), 500

    row = data[0] if data else {}
    total_enq = row.get('total_enquiries', 0) or 0
    converted = row.get('converted_enquiries', 0) or 0
    row['conversion_rate'] = round(converted * 100.0 / total_enq, 1) if total_enq > 0 else 0

    return jsonify({'status': 'success', 'data': row})


# ═══════════════════════════════════════════════════════════════════════════════
# API : Query 1 — Invoice / Booking History
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/reports/invoice/<int:customer_id>', methods=['GET'])
def invoice_report(customer_id):
    """Full customer journey: enquiry → sale → payments."""
    query = """
        WITH customer_enquiry_trail AS (
            SELECT
                e.enquiry_id, e.customer_id,
                CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
                c.phone AS customer_phone, c.email AS customer_email, c.city AS customer_city,
                e.enquiry_date, e.source AS enquiry_source, e.status AS enquiry_status,
                e.remarks AS enquiry_remarks,
                ROW_NUMBER() OVER (PARTITION BY e.customer_id ORDER BY e.enquiry_date ASC) AS enquiry_sequence,
                v.variant_name AS enquired_variant, v.fuel_type, v.transmission,
                v.ex_showroom_price AS listed_price,
                m.model_name, ct.type_name AS car_type,
                cl.colour_name AS preferred_colour,
                br.branch_name, d.dealer_name,
                CONCAT(emp.first_name, ' ', emp.last_name) AS sales_executive
            FROM enquiries e
            JOIN customers c ON c.customer_id = e.customer_id
            JOIN variants v ON v.variant_id = e.variant_id
            JOIN models m ON m.model_id = v.model_id
            JOIN car_types ct ON ct.car_type_id = m.car_type_id
            LEFT JOIN colours cl ON cl.colour_id = e.colour_id
            JOIN branches br ON br.branch_id = e.branch_id
            JOIN dealers d ON d.dealer_id = br.dealer_id
            LEFT JOIN employees emp ON emp.employee_id = e.employee_id
        ),
        sale_details AS (
            SELECT
                s.sale_id, s.enquiry_id, s.customer_id, s.sale_date, s.vin_number,
                v.variant_name AS sold_variant, m.model_name AS sold_model,
                cl.colour_name AS delivered_colour,
                s.ex_showroom_price AS sale_ex_showroom, s.gst_percent, s.gst_amount,
                ROUND(s.gst_amount / 2, 2) AS cgst_amount,
                ROUND(s.gst_amount / 2, 2) AS sgst_amount,
                s.road_tax, s.insurance, s.accessories, s.total_on_road,
                s.delivery_status, s.delivery_date,
                br.branch_name AS sale_branch,
                CONCAT(emp.first_name, ' ', emp.last_name) AS closing_executive
            FROM sales s
            JOIN variants v ON v.variant_id = s.variant_id
            JOIN models m ON m.model_id = v.model_id
            JOIN colours cl ON cl.colour_id = s.colour_id
            JOIN branches br ON br.branch_id = s.branch_id
            JOIN employees emp ON emp.employee_id = s.employee_id
        ),
        payment_ledger AS (
            SELECT
                py.payment_id, py.sale_id, py.payment_date, py.amount,
                py.payment_mode, py.reference_no, py.status AS payment_status,
                SUM(py.amount) OVER (PARTITION BY py.sale_id ORDER BY py.payment_date, py.payment_id) AS running_total,
                SUM(py.amount) OVER (PARTITION BY py.sale_id) AS total_paid
            FROM payments py
        )
        SELECT
            cet.customer_name, cet.customer_phone, cet.customer_email,
            cet.enquiry_id, cet.enquiry_sequence, cet.enquiry_date,
            cet.enquiry_source, cet.enquiry_status, cet.car_type,
            cet.model_name AS enquired_model, cet.enquired_variant,
            cet.preferred_colour, cet.listed_price,
            cet.branch_name, cet.dealer_name, cet.sales_executive,
            sd.sale_id, sd.sale_date, sd.vin_number,
            sd.sold_model, sd.sold_variant, sd.delivered_colour,
            sd.sale_ex_showroom, sd.gst_percent, sd.cgst_amount, sd.sgst_amount,
            sd.gst_amount AS total_gst, sd.road_tax, sd.insurance, sd.accessories,
            sd.total_on_road, sd.delivery_status, sd.delivery_date,
            pl.payment_date, pl.amount AS payment_amount, pl.payment_mode,
            pl.reference_no, pl.payment_status, pl.running_total, pl.total_paid,
            ROUND(sd.total_on_road - COALESCE(pl.total_paid, 0), 2) AS balance_due
        FROM customer_enquiry_trail cet
        LEFT JOIN sale_details sd ON sd.enquiry_id = cet.enquiry_id AND sd.customer_id = cet.customer_id
        LEFT JOIN payment_ledger pl ON pl.sale_id = sd.sale_id
        WHERE cet.customer_id = %s
        ORDER BY cet.enquiry_date, sd.sale_date, pl.payment_date
    """
    data, err = execute_query(query, (customer_id,))
    if err:
        return jsonify({'error': err}), 500
    return jsonify({'status': 'success', 'data': data})


# ═══════════════════════════════════════════════════════════════════════════════
# API : Query 2 — Lead Conversion Report
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/reports/lead-conversion', methods=['GET'])
def lead_conversion():
    """Branch-level lead conversion summary."""
    query = """
        SELECT
            br.branch_name, br.city AS branch_city, d.dealer_name,
            COUNT(*) AS total_enquiries,
            SUM(CASE WHEN e.status = 'Converted' THEN 1 ELSE 0 END) AS converted,
            SUM(CASE WHEN e.status = 'Lost' THEN 1 ELSE 0 END) AS lost,
            SUM(CASE WHEN e.status NOT IN ('Converted', 'Lost') THEN 1 ELSE 0 END) AS in_pipeline,
            ROUND(SUM(CASE WHEN e.status = 'Converted' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS conversion_rate
        FROM enquiries e
        JOIN branches br ON br.branch_id = e.branch_id
        JOIN dealers d ON d.dealer_id = br.dealer_id
        WHERE YEAR(e.enquiry_date) = 2025
        GROUP BY br.branch_id, br.branch_name, br.city, d.dealer_name
        ORDER BY conversion_rate DESC
    """
    data, err = execute_query(query)
    if err:
        return jsonify({'error': err}), 500
    return jsonify({'status': 'success', 'data': data})


# ═══════════════════════════════════════════════════════════════════════════════
# API : Query 3 — Annual Sales Report (Monthly Breakdown)
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/reports/annual-sales', methods=['GET'])
def annual_sales():
    """Month-by-month sales breakdown for Chart.js visualization."""
    year = request.args.get('year', 2025, type=int)

    # Monthly aggregated sales
    monthly_query = """
        SELECT
            MONTH(s.sale_date) AS month_num,
            MONTHNAME(s.sale_date) AS month_name,
            COUNT(*) AS units_sold,
            SUM(s.total_on_road) AS revenue
        FROM sales s
        WHERE s.delivery_status <> 'Cancelled' AND YEAR(s.sale_date) = %s
        GROUP BY MONTH(s.sale_date), MONTHNAME(s.sale_date)
        ORDER BY month_num
    """
    monthly_data, err1 = execute_query(monthly_query, (year,))

    # Branch-wise revenue (for pie chart)
    branch_query = """
        SELECT
            br.branch_name,
            br.city,
            COUNT(*) AS units_sold,
            SUM(s.total_on_road) AS revenue,
            ROUND(SUM(s.total_on_road) * 100.0 / (
                SELECT SUM(s2.total_on_road) FROM sales s2
                WHERE s2.delivery_status <> 'Cancelled' AND YEAR(s2.sale_date) = %s
            ), 2) AS pct_contribution
        FROM sales s
        JOIN branches br ON br.branch_id = s.branch_id
        WHERE s.delivery_status <> 'Cancelled' AND YEAR(s.sale_date) = %s
        GROUP BY br.branch_id, br.branch_name, br.city
        ORDER BY revenue DESC
    """
    branch_data, err2 = execute_query(branch_query, (year, year))

    # Colour-wise breakdown (for pie chart)
    colour_query = """
        SELECT
            cl.colour_name,
            cl.hex_code,
            COUNT(*) AS units_sold,
            SUM(s.total_on_road) AS revenue
        FROM sales s
        JOIN colours cl ON cl.colour_id = s.colour_id
        WHERE s.delivery_status <> 'Cancelled' AND YEAR(s.sale_date) = %s
        GROUP BY cl.colour_id, cl.colour_name, cl.hex_code
        ORDER BY units_sold DESC
    """
    colour_data, err3 = execute_query(colour_query, (year,))

    # Model-wise breakdown
    model_query = """
        SELECT
            m.model_name,
            ct.type_name AS car_type,
            COUNT(*) AS units_sold,
            SUM(s.total_on_road) AS revenue
        FROM sales s
        JOIN variants v ON v.variant_id = s.variant_id
        JOIN models m ON m.model_id = v.model_id
        JOIN car_types ct ON ct.car_type_id = m.car_type_id
        WHERE s.delivery_status <> 'Cancelled' AND YEAR(s.sale_date) = %s
        GROUP BY m.model_id, m.model_name, ct.type_name
        ORDER BY units_sold DESC
    """
    model_data, err4 = execute_query(model_query, (year,))

    if err1 or err2 or err3 or err4:
        return jsonify({'error': err1 or err2 or err3 or err4}), 500

    return jsonify({
        'status': 'success',
        'data': {
            'monthly': monthly_data,
            'by_branch': branch_data,
            'by_colour': colour_data,
            'by_model': model_data,
            'year': year
        }
    })


# ═══════════════════════════════════════════════════════════════════════════════
# API : Query 4 — Regional Performance (Variant-Level City Sales)
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/reports/regional-performance', methods=['GET'])
def regional_performance():
    """Breakdown of Units and Revenue per Variant across Cities."""
    query = """
        WITH sales_base AS (
            SELECT 
                m.model_name, v.variant_name, br.city,
                s.total_on_road, s.sale_id
            FROM sales s
            JOIN variants v ON s.variant_id = v.variant_id
            JOIN models m ON v.model_id = m.model_id
            JOIN branches br ON s.branch_id = br.branch_id
            WHERE s.delivery_status <> 'Cancelled'
        ),
        city_aggregates AS (
            SELECT 
                model_name, variant_name, city,
                COUNT(*) AS units, SUM(total_on_road) AS revenue
            FROM sales_base
            GROUP BY model_name, variant_name, city
        )
        SELECT 
            model_name, variant_name,
            SUM(CASE WHEN city = 'Chennai' THEN units ELSE 0 END) AS chennai_units,
            SUM(CASE WHEN city = 'Chennai' THEN revenue ELSE 0 END) AS chennai_revenue,
            SUM(CASE WHEN city = 'Bengaluru' THEN units ELSE 0 END) AS bengaluru_units,
            SUM(CASE WHEN city = 'Bengaluru' THEN revenue ELSE 0 END) AS bengaluru_revenue,
            SUM(CASE WHEN city = 'Hyderabad' THEN units ELSE 0 END) AS hyderabad_units,
            SUM(CASE WHEN city = 'Hyderabad' THEN revenue ELSE 0 END) AS hyderabad_revenue,
            SUM(CASE WHEN city = 'New Delhi' THEN units ELSE 0 END) AS delhi_units,
            SUM(CASE WHEN city = 'New Delhi' THEN revenue ELSE 0 END) AS delhi_revenue,
            SUM(CASE WHEN city = 'Mumbai' THEN units ELSE 0 END) AS mumbai_units,
            SUM(CASE WHEN city = 'Mumbai' THEN revenue ELSE 0 END) AS mumbai_revenue,
            SUM(units) AS total_units,
            SUM(revenue) AS total_revenue
        FROM city_aggregates
        GROUP BY model_name, variant_name
        ORDER BY model_name, variant_name
    """
    data, err = execute_query(query)
    if err:
        return jsonify({'error': err}), 500
    return jsonify({'status': 'success', 'data': data})


# ═══════════════════════════════════════════════════════════════════════════════
# API : Customer List (for Invoice lookup dropdown)
# ═══════════════════════════════════════════════════════════════════════════════

@app.route('/api/customers', methods=['GET'])
def list_customers():
    query = """
        SELECT customer_id, CONCAT(first_name, ' ', last_name) AS name,
               phone, city
        FROM customers ORDER BY first_name
    """
    data, err = execute_query(query)
    if err:
        return jsonify({'error': err}), 500
    return jsonify({'status': 'success', 'data': data})


# ═══════════════════════════════════════════════════════════════════════════════
# RUN SERVER
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
