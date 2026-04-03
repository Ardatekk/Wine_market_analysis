-- Keyword cluster analysis for wines that match ALL requested flavor terms.
-- Requirements implemented:
-- - case-sensitive keyword matching via COLLATE BINARY
-- - only keyword confirmations above 10 users
-- - include group_name
-- - keep only wines that contain all five keywords:
--   coffee, toast, green apple, cream, citrus

WITH keyword_matches AS (
    SELECT
        w.id AS wine_id,
        w.name AS wine_name,
        c.name AS country_name,
        r.name AS region_name,
        k.name AS keyword_name,
        kw.group_name,
        kw.count AS confirmations,
        w.ratings_average,
        w.ratings_count
    FROM keywords_wine kw
    JOIN keywords k
        ON k.id = kw.keyword_id
    JOIN wines w
        ON w.id = kw.wine_id
    JOIN regions r
        ON r.id = w.region_id
    JOIN countries c
        ON c.code = r.country_code
    WHERE k.name COLLATE BINARY IN ('coffee', 'toast', 'green apple', 'cream', 'citrus')
      AND kw.count > 10
),
qualified_wines AS (
    SELECT
        wine_id
    FROM keyword_matches
    GROUP BY wine_id
    HAVING COUNT(DISTINCT keyword_name) = 5
)
SELECT
    km.wine_id,
    km.wine_name,
    km.country_name,
    km.region_name,
    km.keyword_name,
    km.group_name,
    km.confirmations,
    km.ratings_average,
    km.ratings_count
FROM keyword_matches km
JOIN qualified_wines qw
    ON km.wine_id = qw.wine_id
ORDER BY km.wine_id, km.confirmations DESC, km.keyword_name;
