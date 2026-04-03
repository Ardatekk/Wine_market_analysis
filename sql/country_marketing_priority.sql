-- Country priority model for marketing budget allocation.
-- Business logic:
-- marketing should favor markets that combine:
-- 1. strong average wine quality
-- 2. large wine assortment
-- 3. high user engagement
-- The score below normalizes each metric and weights:
-- - average wine rating: 45%
-- - users_count engagement: 30%
-- - wines_count assortment depth: 25%
-- The top-ranked country is the primary marketing recommendation.

WITH country_metrics AS (
    SELECT
        c.code,
        c.name AS country_name,
        c.wines_count,
        c.users_count,
        COUNT(w.id) AS sampled_wines,
        AVG(w.ratings_average) AS avg_wine_rating,
        AVG(w.ratings_count) AS avg_rating_count
    FROM countries c
    LEFT JOIN regions r
        ON r.country_code = c.code
    LEFT JOIN wines w
        ON w.region_id = r.id
    GROUP BY c.code, c.name, c.wines_count, c.users_count
    HAVING COUNT(w.id) > 0
),
bounds AS (
    SELECT
        MIN(avg_wine_rating) AS min_rating,
        MAX(avg_wine_rating) AS max_rating,
        MIN(wines_count) AS min_wines,
        MAX(wines_count) AS max_wines,
        MIN(users_count) AS min_users,
        MAX(users_count) AS max_users
    FROM country_metrics
),
scored_countries AS (
    SELECT
        cm.code,
        cm.country_name,
        cm.wines_count,
        cm.users_count,
        cm.sampled_wines,
        ROUND(cm.avg_wine_rating, 3) AS avg_wine_rating,
        ROUND(cm.avg_rating_count, 1) AS avg_rating_count,
        ROUND(
            0.45 * ((cm.avg_wine_rating - b.min_rating) / NULLIF(b.max_rating - b.min_rating, 0)) +
            0.30 * ((cm.users_count - b.min_users) / NULLIF(b.max_users - b.min_users, 0)) +
            0.25 * ((cm.wines_count - b.min_wines) / NULLIF(b.max_wines - b.min_wines, 0)),
            4
        ) AS marketing_priority_score
    FROM country_metrics cm
    CROSS JOIN bounds b
)
SELECT
    code,
    country_name,
    wines_count,
    users_count,
    sampled_wines,
    avg_wine_rating,
    avg_rating_count,
    marketing_priority_score,
    CASE
        WHEN ROW_NUMBER() OVER (ORDER BY marketing_priority_score DESC, users_count DESC) = 1
            THEN 'Primary recommendation for near-term marketing budget.'
        WHEN marketing_priority_score >= 0.50
            THEN 'High-priority market with strong commercial fundamentals.'
        WHEN marketing_priority_score >= 0.30
            THEN 'Secondary market worth targeted campaigns.'
        ELSE 'Monitor rather than prioritize for broad marketing spend.'
    END AS marketing_conclusion
FROM scored_countries
ORDER BY marketing_priority_score DESC, users_count DESC;
