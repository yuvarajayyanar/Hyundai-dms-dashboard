-- =============================================================================
-- QUERY 2 :  LEAD CONVERSION & ENQUIRY REPORT
-- Deep-dive into customer interests vs actual conversions at each branch,
-- with stock availability indicators and conversion funnel metrics.
-- Uses: CTEs, Window Functions (RANK, SUM OVER, COUNT OVER), Complex Joins
-- =============================================================================

WITH
-- ─────────────────────────────────────────────────────────────────────────────
-- CTE 1 : All enquiries enriched with model / variant / branch context
-- ─────────────────────────────────────────────────────────────────────────────
enriched_enquiries AS (
    SELECT
        e.enquiry_id,
        e.customer_id,
        CONCAT(c.first_name, ' ', c.last_name)           AS customer_name,
        c.phone                                           AS customer_phone,
        c.city                                            AS customer_city,
        e.enquiry_date,
        e.source                                          AS enquiry_source,
        e.status                                          AS enquiry_status,
        e.expected_purchase_date,
        e.remarks,

        -- Vehicle interest
        ct.type_name                                      AS car_type,
        m.model_name,
        v.variant_id,
        v.variant_name,
        v.fuel_type,
        v.transmission,
        v.ex_showroom_price                               AS variant_price,
        cl.colour_name                                    AS preferred_colour,

        -- Branch context
        e.branch_id,
        br.branch_name,
        br.branch_code,
        br.city                                           AS branch_city,
        br.state                                          AS branch_state,
        d.dealer_name,
        d.dealer_code,

        -- Sales executive
        CONCAT(emp.first_name, ' ', emp.last_name)       AS assigned_executive,

        -- Temporal analysis
        YEAR(e.enquiry_date)                              AS enquiry_year,
        MONTH(e.enquiry_date)                             AS enquiry_month,
        QUARTER(e.enquiry_date)                           AS enquiry_quarter,

        -- Flag converted
        CASE WHEN e.status = 'Converted' THEN 1 ELSE 0 END AS is_converted,
        CASE WHEN e.status = 'Lost'      THEN 1 ELSE 0 END AS is_lost

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
-- CTE 2 : Actual sales per branch × variant × colour (proxy for stock sold)
-- ─────────────────────────────────────────────────────────────────────────────
branch_variant_sales AS (
    SELECT
        s.branch_id,
        s.variant_id,
        s.colour_id,
        cl.colour_name,
        COUNT(*)                                          AS units_sold,
        SUM(s.total_on_road)                              AS total_revenue
    FROM      sales    s
    JOIN      colours  cl  ON cl.colour_id = s.colour_id
    WHERE     s.delivery_status <> 'Cancelled'
    GROUP BY  s.branch_id, s.variant_id, s.colour_id, cl.colour_name
),

-- ─────────────────────────────────────────────────────────────────────────────
-- CTE 3 : Branch-level conversion KPIs
-- ─────────────────────────────────────────────────────────────────────────────
branch_conversion_kpi AS (
    SELECT
        branch_id,
        branch_name,
        branch_city,
        dealer_name,

        COUNT(*)                                          AS total_enquiries,
        SUM(is_converted)                                 AS total_converted,
        SUM(is_lost)                                      AS total_lost,
        COUNT(*) - SUM(is_converted) - SUM(is_lost)       AS still_in_pipeline,

        ROUND(
            SUM(is_converted) * 100.0 / NULLIF(COUNT(*), 0), 2
        )                                                 AS conversion_rate_pct,

        -- Average days from enquiry to expected purchase
        ROUND(
            AVG(DATEDIFF(expected_purchase_date, enquiry_date)), 1
        )                                                 AS avg_days_to_decision,

        -- Top enquiry source per branch (most frequent)
        (
            SELECT  ee2.enquiry_source
            FROM    enriched_enquiries ee2
            WHERE   ee2.branch_id = ee.branch_id
            GROUP BY ee2.enquiry_source
            ORDER BY COUNT(*) DESC
            LIMIT 1
        )                                                 AS top_enquiry_source

    FROM enriched_enquiries ee
    GROUP BY branch_id, branch_name, branch_city, dealer_name
),

-- ─────────────────────────────────────────────────────────────────────────────
-- CTE 4 : Model popularity ranking across all branches
-- ─────────────────────────────────────────────────────────────────────────────
model_popularity AS (
    SELECT
        model_name,
        car_type,
        branch_id,
        branch_name,
        COUNT(*)                                          AS enquiry_count,
        SUM(is_converted)                                 AS converted_count,

        RANK() OVER (
            PARTITION BY branch_id
            ORDER BY COUNT(*) DESC
        )                                                 AS popularity_rank_in_branch,

        -- Percentage of all enquiries this model represents
        ROUND(
            COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY branch_id),
            2
        )                                                 AS pct_of_branch_enquiries

    FROM enriched_enquiries
    GROUP BY model_name, car_type, branch_id, branch_name
)

-- ═══════════════════════════════════════════════════════════════════════════
-- FINAL SELECT : Combine per-enquiry detail with branch KPIs & stock availability
-- ═══════════════════════════════════════════════════════════════════════════
SELECT
    -- ── Enquiry detail ──
    ee.enquiry_id,
    ee.customer_name,
    ee.customer_phone,
    ee.customer_city,
    ee.enquiry_date,
    ee.enquiry_source,
    ee.enquiry_status,
    ee.expected_purchase_date,

    -- ── Vehicle interest ──
    ee.car_type,
    ee.model_name,
    ee.variant_name,
    ee.fuel_type,
    ee.transmission,
    ee.variant_price,
    ee.preferred_colour,

    -- ── Branch & dealer ──
    ee.branch_name,
    ee.branch_city,
    ee.dealer_name,
    ee.assigned_executive,

    -- ── Stock availability at this branch for this variant + colour ──
    COALESCE(bvs.units_sold, 0)                          AS units_sold_this_combo,
    COALESCE(bvs.total_revenue, 0)                       AS revenue_this_combo,
    CASE
        WHEN bvs.units_sold IS NOT NULL
            THEN 'Available (sold previously)'
        ELSE 'No stock history — may need allocation'
    END                                                   AS stock_availability_indicator,

    -- ── Branch conversion metrics ──
    bck.total_enquiries                                   AS branch_total_enquiries,
    bck.total_converted                                   AS branch_total_converted,
    bck.conversion_rate_pct                               AS branch_conversion_rate,
    bck.avg_days_to_decision                              AS branch_avg_decision_days,
    bck.top_enquiry_source                                AS branch_top_source,
    bck.still_in_pipeline                                 AS branch_pipeline_count,

    -- ── Model popularity at this branch ──
    mp.popularity_rank_in_branch,
    mp.enquiry_count                                      AS model_enquiries_at_branch,
    mp.pct_of_branch_enquiries                            AS model_share_pct,

    -- ── Running conversion count by branch over time ──
    SUM(ee.is_converted) OVER (
        PARTITION BY ee.branch_id
        ORDER BY ee.enquiry_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                     AS cumulative_conversions

FROM      enriched_enquiries       ee
LEFT JOIN branch_variant_sales     bvs  ON bvs.branch_id  = ee.branch_id
                                        AND bvs.variant_id = ee.variant_id
                                        AND bvs.colour_name = ee.preferred_colour
LEFT JOIN branch_conversion_kpi    bck  ON bck.branch_id   = ee.branch_id
LEFT JOIN model_popularity         mp   ON mp.branch_id    = ee.branch_id
                                        AND mp.model_name  = ee.model_name

ORDER BY
    ee.branch_name  ASC,
    ee.enquiry_date ASC;
