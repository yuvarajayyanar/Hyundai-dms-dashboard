-- =============================================================================
-- QUERY 1 :  INVOICE / BOOKING HISTORY
-- Customer journey from enquiry ➜ sale ➜ payments with tax break-up
-- Uses: CTEs, Window Functions, Complex Joins
-- =============================================================================

WITH
-- ─────────────────────────────────────────────────────────────────────────────
-- CTE 1 : Gather the full enquiry trail for the target customer
-- ─────────────────────────────────────────────────────────────────────────────
customer_enquiry_trail AS (
    SELECT
        e.enquiry_id,
        e.customer_id,
        CONCAT(c.first_name, ' ', c.last_name)       AS customer_name,
        c.phone                                       AS customer_phone,
        c.email                                       AS customer_email,
        c.city                                        AS customer_city,
        e.enquiry_date,
        e.source                                      AS enquiry_source,
        e.status                                      AS enquiry_status,
        e.expected_purchase_date,
        e.remarks                                     AS enquiry_remarks,

        -- Rank enquiries by date to see progression
        ROW_NUMBER() OVER (
            PARTITION BY e.customer_id
            ORDER BY e.enquiry_date ASC
        )                                             AS enquiry_sequence,

        -- Variant details at enquiry time
        v.variant_id,
        v.variant_name                                AS enquired_variant,
        v.fuel_type,
        v.transmission,
        v.engine_cc,
        v.ex_showroom_price                           AS listed_price,

        -- Model & type
        m.model_name,
        ct.type_name                                  AS car_type,

        -- Preferred colour
        cl.colour_name                                AS preferred_colour,

        -- Branch & dealer
        br.branch_name,
        br.city                                       AS branch_city,
        d.dealer_name,

        -- Assigned sales person
        CONCAT(emp.first_name, ' ', emp.last_name)   AS sales_executive

    FROM      enquiries   e
    JOIN      customers   c    ON c.customer_id  = e.customer_id
    JOIN      variants    v    ON v.variant_id   = e.variant_id
    JOIN      models      m    ON m.model_id     = v.model_id
    JOIN      car_types   ct   ON ct.car_type_id = m.car_type_id
    LEFT JOIN colours     cl   ON cl.colour_id   = e.colour_id
    JOIN      branches    br   ON br.branch_id   = e.branch_id
    JOIN      dealers     d    ON d.dealer_id    = br.dealer_id
    LEFT JOIN employees   emp  ON emp.employee_id = e.employee_id
),

-- ─────────────────────────────────────────────────────────────────────────────
-- CTE 2 : Sale records linked back to enquiries
-- ─────────────────────────────────────────────────────────────────────────────
sale_details AS (
    SELECT
        s.sale_id,
        s.enquiry_id,
        s.customer_id,
        s.sale_date,
        s.vin_number,

        -- Sold variant
        v.variant_name                                AS sold_variant,
        v.fuel_type                                   AS sold_fuel,
        v.transmission                                AS sold_transmission,
        v.engine_cc                                   AS sold_engine_cc,
        m.model_name                                  AS sold_model,
        ct.type_name                                  AS sold_car_type,
        cl.colour_name                                AS delivered_colour,

        -- Price components
        s.ex_showroom_price                           AS sale_ex_showroom,
        s.gst_percent,
        s.gst_amount,
        s.road_tax,
        s.insurance,
        s.accessories,
        s.total_on_road,

        -- CGST / SGST split (equal halves of GST for intra-state)
        ROUND(s.gst_amount / 2, 2)                   AS cgst_amount,
        ROUND(s.gst_amount / 2, 2)                   AS sgst_amount,

        -- Delivery
        s.delivery_status,
        s.delivery_date,

        -- Branch / staff
        br.branch_name                                AS sale_branch,
        br.city                                       AS sale_city,
        CONCAT(emp.first_name, ' ', emp.last_name)   AS closing_executive,
        p.plant_name                                  AS manufacturing_plant

    FROM      sales       s
    JOIN      variants    v    ON v.variant_id   = s.variant_id
    JOIN      models      m    ON m.model_id     = v.model_id
    JOIN      car_types   ct   ON ct.car_type_id = m.car_type_id
    JOIN      colours     cl   ON cl.colour_id   = s.colour_id
    JOIN      branches    br   ON br.branch_id   = s.branch_id
    JOIN      employees   emp  ON emp.employee_id = s.employee_id
    LEFT JOIN plants      p    ON p.plant_id     = s.plant_id
),

-- ─────────────────────────────────────────────────────────────────────────────
-- CTE 3 : Payment ledger per sale with running totals
-- ─────────────────────────────────────────────────────────────────────────────
payment_ledger AS (
    SELECT
        py.payment_id,
        py.sale_id,
        py.payment_date,
        py.amount,
        py.payment_mode,
        py.reference_no,
        py.status                                     AS payment_status,
        py.remarks                                    AS payment_remarks,

        -- Running total of payments per sale (chronological order)
        SUM(py.amount) OVER (
            PARTITION BY py.sale_id
            ORDER BY py.payment_date, py.payment_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                                             AS running_total_paid,

        -- Total paid for this sale
        SUM(py.amount) OVER (
            PARTITION BY py.sale_id
        )                                             AS total_paid_for_sale,

        -- Payment sequence number
        ROW_NUMBER() OVER (
            PARTITION BY py.sale_id
            ORDER BY py.payment_date, py.payment_id
        )                                             AS payment_seq

    FROM payments py
)

-- ═══════════════════════════════════════════════════════════════════════════
-- FINAL SELECT : Merge enquiry trail → sale → payment ledger
-- ═══════════════════════════════════════════════════════════════════════════
SELECT
    -- ── Customer header ──
    cet.customer_name,
    cet.customer_phone,
    cet.customer_email,
    cet.customer_city,

    -- ── Enquiry timeline ──
    cet.enquiry_id,
    cet.enquiry_sequence,
    cet.enquiry_date,
    cet.enquiry_source,
    cet.enquiry_status,
    cet.car_type                                      AS enquired_car_type,
    cet.model_name                                    AS enquired_model,
    cet.enquired_variant,
    cet.fuel_type                                     AS enquired_fuel,
    cet.transmission                                  AS enquired_transmission,
    cet.preferred_colour,
    cet.listed_price,
    cet.branch_name                                   AS enquiry_branch,
    cet.dealer_name,
    cet.sales_executive,
    cet.enquiry_remarks,

    -- ── Sale details ──
    sd.sale_id,
    sd.sale_date,
    sd.vin_number,
    sd.sold_car_type,
    sd.sold_model,
    sd.sold_variant,
    sd.sold_fuel,
    sd.sold_transmission,
    sd.sold_engine_cc,
    sd.delivered_colour,
    sd.manufacturing_plant,

    -- ── Tax invoice breakdown ──
    sd.sale_ex_showroom,
    sd.gst_percent,
    sd.cgst_amount,
    sd.sgst_amount,
    sd.gst_amount                                     AS total_gst,
    sd.road_tax,
    sd.insurance,
    sd.accessories,
    sd.total_on_road,

    -- ── Delivery ──
    sd.delivery_status,
    sd.delivery_date,
    sd.sale_branch,
    sd.closing_executive,

    -- ── Payment ledger ──
    pl.payment_seq,
    pl.payment_date,
    pl.amount                                         AS payment_amount,
    pl.payment_mode,
    pl.reference_no,
    pl.payment_status,
    pl.running_total_paid,
    pl.total_paid_for_sale,
    ROUND(sd.total_on_road - pl.total_paid_for_sale, 2) AS balance_due

FROM      customer_enquiry_trail  cet
LEFT JOIN sale_details            sd   ON sd.enquiry_id  = cet.enquiry_id
                                       AND sd.customer_id = cet.customer_id
LEFT JOIN payment_ledger          pl   ON pl.sale_id     = sd.sale_id

-- ═══════════════════════════════════════════════════════════════════════════
-- FILTER : Pass customer_id = ? to generate invoice for a specific customer
-- ═══════════════════════════════════════════════════════════════════════════
WHERE cet.customer_id = 1

ORDER BY
    cet.enquiry_date ASC,
    sd.sale_date     ASC,
    pl.payment_seq   ASC;
