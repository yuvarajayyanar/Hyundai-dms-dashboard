-- =============================================================================
-- QUERY 3 :  EXECUTIVE ANNUAL SALES REPORT  (Jan – Dec 2025)
-- Month-by-month breakdown of cars sold grouped by Location, Colour, Variant.
-- Includes Grand Totals via ROLLUP and percentage contribution of each branch.
-- Uses: CTEs, Window Functions (SUM OVER, RANK), ROLLUP, Complex Joins
-- =============================================================================

WITH
-- ─────────────────────────────────────────────────────────────────────────────
-- CTE 1 : Enrich every sale with dimensional attributes
-- ─────────────────────────────────────────────────────────────────────────────
enriched_sales AS (
    SELECT
        s.sale_id,
        s.sale_date,
        YEAR(s.sale_date)                                  AS sale_year,
        MONTH(s.sale_date)                                 AS sale_month,
        MONTHNAME(s.sale_date)                             AS month_name,

        -- Branch / Location
        br.branch_id,
        br.branch_name,
        br.branch_code,
        br.city                                            AS branch_city,
        br.state                                           AS branch_state,
        d.dealer_name,

        -- Vehicle
        ct.type_name                                       AS car_type,
        m.model_name,
        v.variant_name,
        v.fuel_type,
        v.transmission,
        cl.colour_name,

        -- Revenue
        s.ex_showroom_price,
        s.gst_amount,
        s.road_tax,
        s.insurance,
        s.accessories,
        s.total_on_road

    FROM      sales      s
    JOIN      branches   br  ON br.branch_id   = s.branch_id
    JOIN      dealers    d   ON d.dealer_id    = br.dealer_id
    JOIN      variants   v   ON v.variant_id   = s.variant_id
    JOIN      models     m   ON m.model_id     = v.model_id
    JOIN      car_types  ct  ON ct.car_type_id = m.car_type_id
    JOIN      colours    cl  ON cl.colour_id   = s.colour_id
    WHERE     s.delivery_status <> 'Cancelled'
      AND     YEAR(s.sale_date) = 2025
),

-- ─────────────────────────────────────────────────────────────────────────────
-- CTE 2 : Monthly pivot per branch × colour × variant
-- ─────────────────────────────────────────────────────────────────────────────
monthly_breakdown AS (
    SELECT
        branch_name,
        branch_city,
        branch_state,
        dealer_name,
        colour_name,
        model_name,
        variant_name,
        fuel_type,

        -- Monthly unit counts
        SUM(CASE WHEN sale_month = 1  THEN 1 ELSE 0 END) AS Jan,
        SUM(CASE WHEN sale_month = 2  THEN 1 ELSE 0 END) AS Feb,
        SUM(CASE WHEN sale_month = 3  THEN 1 ELSE 0 END) AS Mar,
        SUM(CASE WHEN sale_month = 4  THEN 1 ELSE 0 END) AS Apr,
        SUM(CASE WHEN sale_month = 5  THEN 1 ELSE 0 END) AS May_,
        SUM(CASE WHEN sale_month = 6  THEN 1 ELSE 0 END) AS Jun,
        SUM(CASE WHEN sale_month = 7  THEN 1 ELSE 0 END) AS Jul,
        SUM(CASE WHEN sale_month = 8  THEN 1 ELSE 0 END) AS Aug,
        SUM(CASE WHEN sale_month = 9  THEN 1 ELSE 0 END) AS Sep,
        SUM(CASE WHEN sale_month = 10 THEN 1 ELSE 0 END) AS Oct,
        SUM(CASE WHEN sale_month = 11 THEN 1 ELSE 0 END) AS Nov,
        SUM(CASE WHEN sale_month = 12 THEN 1 ELSE 0 END) AS Dec_,

        -- Annual totals
        COUNT(*)                                           AS total_units,
        SUM(total_on_road)                                 AS total_revenue,
        SUM(ex_showroom_price)                             AS total_ex_showroom,
        SUM(gst_amount)                                    AS total_gst_collected,
        ROUND(AVG(total_on_road), 2)                       AS avg_ticket_size

    FROM enriched_sales
    GROUP BY
        branch_name, branch_city, branch_state, dealer_name,
        colour_name, model_name, variant_name, fuel_type
),

-- ─────────────────────────────────────────────────────────────────────────────
-- CTE 3 : Grand total revenue for percentage calculations
-- ─────────────────────────────────────────────────────────────────────────────
grand_totals AS (
    SELECT
        SUM(total_on_road)                                 AS overall_revenue,
        COUNT(*)                                           AS overall_units
    FROM enriched_sales
),

-- ─────────────────────────────────────────────────────────────────────────────
-- CTE 4 : Branch-level revenue for ranking & contribution percentages
-- ─────────────────────────────────────────────────────────────────────────────
branch_revenue AS (
    SELECT
        branch_name,
        branch_city,
        dealer_name,
        SUM(total_on_road)                                 AS branch_total_revenue,
        COUNT(*)                                           AS branch_total_units,

        RANK() OVER (
            ORDER BY SUM(total_on_road) DESC
        )                                                  AS revenue_rank,

        ROUND(
            SUM(total_on_road) * 100.0 /
            (SELECT overall_revenue FROM grand_totals), 2
        )                                                  AS pct_contribution_revenue,

        ROUND(
            COUNT(*) * 100.0 /
            (SELECT overall_units FROM grand_totals), 2
        )                                                  AS pct_contribution_units

    FROM enriched_sales
    GROUP BY branch_name, branch_city, dealer_name
)

-- ═══════════════════════════════════════════════════════════════════════════
-- FINAL SELECT :  Detailed month-wise report + ROLLUP Grand Total
-- ═══════════════════════════════════════════════════════════════════════════

SELECT
    COALESCE(mb.branch_name,  '*** GRAND TOTAL ***')       AS branch_name,
    COALESCE(mb.branch_city,  '')                          AS city,
    COALESCE(mb.branch_state, '')                          AS state,
    COALESCE(mb.dealer_name,  '')                          AS dealer,
    COALESCE(mb.colour_name,  '-- All Colours --')         AS colour,
    COALESCE(mb.model_name,   '-- All Models --')          AS model,
    COALESCE(mb.variant_name, '-- All Variants --')        AS variant,
    COALESCE(mb.fuel_type,    '')                          AS fuel,

    -- Monthly columns
    SUM(mb.Jan)                                            AS Jan,
    SUM(mb.Feb)                                            AS Feb,
    SUM(mb.Mar)                                            AS Mar,
    SUM(mb.Apr)                                            AS Apr,
    SUM(mb.May_)                                           AS May_,
    SUM(mb.Jun)                                            AS Jun,
    SUM(mb.Jul)                                            AS Jul,
    SUM(mb.Aug)                                            AS Aug,
    SUM(mb.Sep)                                            AS Sep,
    SUM(mb.Oct)                                            AS Oct,
    SUM(mb.Nov)                                            AS Nov,
    SUM(mb.Dec_)                                           AS Dec_,

    -- Aggregates
    SUM(mb.total_units)                                    AS total_units_sold,
    SUM(mb.total_revenue)                                  AS total_revenue,
    SUM(mb.total_ex_showroom)                              AS total_ex_showroom,
    SUM(mb.total_gst_collected)                            AS total_gst,
    ROUND(AVG(mb.avg_ticket_size), 2)                      AS avg_ticket_size,

    -- Branch-level contribution (NULL for ROLLUP summary rows)
    MAX(brv.revenue_rank)                                  AS branch_revenue_rank,
    MAX(brv.pct_contribution_revenue)                      AS branch_pct_revenue,
    MAX(brv.pct_contribution_units)                        AS branch_pct_units

FROM      monthly_breakdown  mb
LEFT JOIN branch_revenue     brv  ON brv.branch_name = mb.branch_name

GROUP BY
    mb.branch_name,
    mb.branch_city,
    mb.branch_state,
    mb.dealer_name,
    mb.colour_name,
    mb.model_name,
    mb.variant_name,
    mb.fuel_type
    WITH ROLLUP

ORDER BY
    CASE WHEN mb.branch_name IS NULL THEN 1 ELSE 0 END,   -- Grand total last
    mb.branch_name,
    mb.model_name,
    mb.variant_name,
    mb.colour_name;
