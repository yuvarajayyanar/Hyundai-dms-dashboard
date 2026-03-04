-- =============================================================================
-- QUERY 4 :  VARIANT-LEVEL CITY PERFORMANCE REPORT
-- Breakdown of Units Sold and Revenue per Variant across all Cities.
-- Includes Grand Totals for Units and Revenue.
-- =============================================================================

WITH 
-- -----------------------------------------------------------------------------
-- CTE 1 : Sales data enriched with Model, Variant, and City
-- -----------------------------------------------------------------------------
sales_base AS (
    SELECT 
        m.model_name,
        v.variant_name,
        br.city,
        s.total_on_road,
        s.sale_id
    FROM sales s
    JOIN variants v ON s.variant_id = v.variant_id
    JOIN models m ON v.model_id = m.model_id
    JOIN branches br ON s.branch_id = br.branch_id
    WHERE s.delivery_status <> 'Cancelled'
),

-- -----------------------------------------------------------------------------
-- CTE 2 : Aggregate by Model, Variant, and City
-- -----------------------------------------------------------------------------
city_aggregates AS (
    SELECT 
        model_name,
        variant_name,
        city,
        COUNT(*) AS units,
        SUM(total_on_road) AS revenue
    FROM sales_base
    GROUP BY model_name, variant_name, city
)

-- ═══════════════════════════════════════════════════════════════════════════
-- FINAL SELECT : Pivot by City (Chennai, Bengaluru, Hyderabad, New Delhi, Mumbai)
-- ═══════════════════════════════════════════════════════════════════════════
SELECT 
    model_name,
    variant_name,
    
    -- Chennai
    SUM(CASE WHEN city = 'Chennai' THEN units ELSE 0 END) AS chennai_units,
    SUM(CASE WHEN city = 'Chennai' THEN revenue ELSE 0 END) AS chennai_revenue,
    
    -- Bengaluru
    SUM(CASE WHEN city = 'Bengaluru' THEN units ELSE 0 END) AS bengaluru_units,
    SUM(CASE WHEN city = 'Bengaluru' THEN revenue ELSE 0 END) AS bengaluru_revenue,
    
    -- Hyderabad
    SUM(CASE WHEN city = 'Hyderabad' THEN units ELSE 0 END) AS hyderabad_units,
    SUM(CASE WHEN city = 'Hyderabad' THEN revenue ELSE 0 END) AS hyderabad_revenue,
    
    -- New Delhi
    SUM(CASE WHEN city = 'New Delhi' THEN units ELSE 0 END) AS delhi_units,
    SUM(CASE WHEN city = 'New Delhi' THEN revenue ELSE 0 END) AS delhi_revenue,
    
    -- Mumbai
    SUM(CASE WHEN city = 'Mumbai' THEN units ELSE 0 END) AS mumbai_units,
    SUM(CASE WHEN city = 'Mumbai' THEN revenue ELSE 0 END) AS mumbai_revenue,
    
    -- Grand Totals
    SUM(units) AS total_units,
    SUM(revenue) AS total_revenue

FROM city_aggregates
GROUP BY model_name, variant_name
ORDER BY model_name, variant_name;
