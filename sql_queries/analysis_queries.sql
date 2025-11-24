/* ============================================================
   Query 1 — Dune Extraction (OOv3 Combined Lifecycle Query)
   Source: umaproject_multichain.optimisticoraclev3_* tables
   ============================================================ */

WITH made AS (
    SELECT
        chain,
        assertionid,
        evt_block_time AS made_time,
        evt_block_number AS made_block,
        asserter,
        caller AS made_caller,
        bond,
        currency,
        claim,
        identifier,
        expirationtime,
        domainid
    FROM umaproject_multichain.optimisticoraclev3_evt_assertionmade
),

disputed AS (
    SELECT
        assertionid,
        evt_block_time AS disputed_time,
        evt_block_number AS disputed_block,
        disputer,
        caller AS dispute_caller
    FROM umaproject_multichain.optimisticoraclev3_evt_assertiondisputed
),

settled AS (
    SELECT
        assertionid,
        evt_block_time AS settled_time,
        evt_block_number AS settled_block,
        disputed AS was_disputed,
        settlementresolution AS resolution,
        bondrecipient,
        settlecaller
    FROM umaproject_multichain.optimisticoraclev3_evt_assertionsettled
)

SELECT
    m.chain,
    m.assertionid,
    m.made_time,
    d.disputed_time,
    s.settled_time,
    s.was_disputed,
    s.resolution,
    m.asserter,
    d.disputer,
    s.bondrecipient,
    s.settlecaller,
    m.bond,
    m.currency,
    m.identifier,
    m.domainid,
    m.claim,
    m.expirationtime
FROM made m
LEFT JOIN disputed d ON m.assertionid = d.assertionid
LEFT JOIN settled s ON m.assertionid = s.assertionid;



/* ============================================================
   Query 2 — Daily Assertions, Disputes, Settlements (2025+)
   Used for daily activity time-series charts
   ============================================================ */

WITH assertions AS (
    SELECT 
        date_trunc('day', made_time) AS ts,
        COUNT(*) AS assertions,
        0 AS disputes,
        0 AS settlements
    FROM uma_assertion_data.uma_oo_v3_results
    WHERE made_time >= '2025-01-01'
    GROUP BY 1
),
disputes AS (
    SELECT
        date_trunc('day', disputed_time) AS ts,
        0 AS assertions,
        COUNT(*) AS disputes,
        0 AS settlements
    FROM uma_assertion_data.uma_oo_v3_results
    WHERE was_disputed = TRUE
      AND disputed_time >= '2025-01-01'
    GROUP BY 1
),
settlements AS (
    SELECT
        date_trunc('day', settled_time) AS ts,
        0 AS assertions,
        0 AS disputes,
        COUNT(*) AS settlements
    FROM uma_assertion_data.uma_oo_v3_results
    WHERE settled_time IS NOT NULL
      AND settled_time >= '2025-01-01'
    GROUP BY 1
)

SELECT 
    ts,
    SUM(assertions) AS assertions,
    SUM(disputes) AS disputes,
    SUM(settlements) AS settlements
FROM (
    SELECT * FROM assertions
    UNION ALL
    SELECT * FROM disputes
    UNION ALL
    SELECT * FROM settlements
) t
GROUP BY ts
ORDER BY ts;



/* ============================================================
   Query 3 — Monthly Settlement Delay (Raw Values)
   Used for distributions and monthly aggregates
   ============================================================ */

SELECT
    date_trunc('month', made_time) AS assertion_month,
    EXTRACT(EPOCH FROM (settled_time - made_time)) / 86400 AS settlement_delay_days
FROM uma_assertion_data.uma_oo_v3_results
WHERE settled_time IS NOT NULL;



/* ============================================================
   Query 4 — Chain-Year Breakdown (ETH, Arbitrum, Others)
   Used for Sunburst Chain → Year visualization
   ============================================================ */

WITH data AS (
    SELECT
        CASE
            WHEN chain IN ('ethereum', 'arbitrum') THEN chain
            ELSE 'others'
        END AS level_1,
        date_trunc('year', made_time) AS year,
        COUNT(*) AS value
    FROM uma_assertion_data.uma_oo_v3_results
    GROUP BY 1, 2
)
SELECT
    level_1,
    CONCAT(EXTRACT(YEAR FROM year), ' (', value, ')') AS level_2,
    value
FROM data
ORDER BY level_1, level_2;



/* ============================================================
   Query 5 — Chain Dominance (%) Over Time
   Zero-filled month × chain matrix avoids broken charts
   ============================================================ */

WITH months AS (
    SELECT generate_series(
        date_trunc('month', MIN(made_time)),
        date_trunc('month', MAX(made_time)),
        interval '1 month'
    ) AS month
    FROM uma_assertion_data.uma_oo_v3_results
),
chains AS (
    SELECT DISTINCT chain
    FROM uma_assertion_data.uma_oo_v3_results
),
month_chain AS (
    SELECT
        m.month,
        c.chain
    FROM months m
    CROSS JOIN chains c
),
raw_counts AS (
    SELECT
        date_trunc('month', made_time) AS month,
        chain,
        COUNT(*) AS chain_count
    FROM uma_assertion_data.uma_oo_v3_results
    GROUP BY 1, 2
),
filled AS (
    SELECT
        mc.month,
        mc.chain,
        COALESCE(rc.chain_count, 0) AS chain_count
    FROM month_chain mc
    LEFT JOIN raw_counts rc
    ON mc.month = rc.month AND mc.chain = rc.chain
),
totals AS (
    SELECT
        month,
        SUM(chain_count) AS total_count
    FROM filled
    GROUP BY 1
)
SELECT
    f.month,
    f.chain,
    f.chain_count,
    CASE
        WHEN t.total_count = 0 THEN 0
        ELSE (f.chain_count * 100.0 / t.total_count)
    END AS dominance_pct
FROM filled f
JOIN totals t USING (month)
ORDER BY month, chain;
