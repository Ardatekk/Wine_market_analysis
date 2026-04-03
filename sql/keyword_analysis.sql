-- Exact case-sensitive keyword analysis for the requested flavor terms.
-- keywords_wine links wines to keywords and includes group_name plus count.
-- COLLATE BINARY preserves case-sensitive matching.
-- Only rows with more than 10 confirmations are returned.
-- Customer taste cluster logic:
-- a wine must match at least 3 distinct requested keywords to qualify.
-- This helps surface wines with richer multi-note flavor profiles instead of
-- wines that only over-index on a single descriptor.

WITH keyword_matches AS (
    SELECT
        w.id AS wine_id,
        w.name AS wine_name,
        k.name AS keyword_name,
        kw.group_name,
        kw.count AS confirmations,
        c.name AS country_name,
        r.name AS region_name,
        w.ratings_average,
        w.ratings_count
    FROM keywords_wine kw
    JOIN keywords k
        ON kw.keyword_id = k.id
    JOIN wines w
        ON kw.wine_id = w.id
    JOIN regions r
        ON w.region_id = r.id
    JOIN countries c
        ON r.country_code = c.code
    WHERE k.name COLLATE BINARY IN ('coffee', 'toast', 'green apple', 'cream', 'citrus')
      AND kw.count > 10
),
qualified_wines AS (
    SELECT
        wine_id
    FROM keyword_matches
    GROUP BY wine_id
    HAVING COUNT(DISTINCT keyword_name) >= 3
)
SELECT
    km.wine_id,
    km.wine_name,
    km.keyword_name,
    km.group_name,
    km.confirmations,
    km.country_name,
    km.region_name,
    km.ratings_average,
    km.ratings_count
FROM keyword_matches km
JOIN qualified_wines qw
    ON km.wine_id = qw.wine_id
ORDER BY km.wine_id, km.confirmations DESC, km.keyword_name;
