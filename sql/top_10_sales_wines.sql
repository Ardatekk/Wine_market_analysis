-- Final 10 wines for sales focus.
-- Business goal:
-- pick wines that balance broad demand with strong perceived quality.
-- Logic:
-- 1. Filter to wines with meaningful market traction and quality floors.
-- 2. Rank each wine separately by popularity (ratings_count) and quality
--    (ratings_average).
-- 3. Convert those ranks into a balanced sales score so the final list favors
--    wines that are both trusted by many users and highly rated.
-- 4. Add a why_selected explanation for commercial reporting.

WITH eligible_wines AS (
    SELECT
        w.id,
        w.name AS wine_name,
        c.name AS country_name,
        r.name AS region_name,
        w.ratings_average,
        w.ratings_count,
        DENSE_RANK() OVER (ORDER BY w.ratings_count DESC) AS popularity_rank,
        DENSE_RANK() OVER (ORDER BY w.ratings_average DESC, w.ratings_count DESC) AS quality_rank,
        COUNT(*) OVER () AS total_eligible_wines
    FROM wines w
    JOIN regions r
        ON w.region_id = r.id
    JOIN countries c
        ON r.country_code = c.code
    WHERE w.ratings_count >= 500
      AND w.ratings_average >= 4.3
),
scored_wines AS (
    SELECT
        *,
        ROUND(
            0.55 * (1.0 - CAST(popularity_rank - 1 AS REAL) / NULLIF(total_eligible_wines - 1, 0)) +
            0.45 * (1.0 - CAST(quality_rank - 1 AS REAL) / NULLIF(total_eligible_wines - 1, 0)),
            4
        ) AS balanced_sales_score,
        CASE
            WHEN ratings_count >= 100000 AND ratings_average >= 4.6 THEN 'Selected for exceptional scale and premium quality.'
            WHEN ratings_count >= 40000 AND ratings_average >= 4.6 THEN 'Selected for strong global demand and elite quality.'
            WHEN ratings_count >= 20000 AND ratings_average >= 4.7 THEN 'Selected for standout quality with proven market traction.'
            ELSE 'Selected for balanced commercial potential across quality and popularity.'
        END AS why_selected
    FROM eligible_wines
)
SELECT
    id,
    wine_name,
    country_name,
    region_name,
    ratings_average,
    ratings_count,
    popularity_rank,
    quality_rank,
    balanced_sales_score,
    why_selected
FROM scored_wines
ORDER BY balanced_sales_score DESC, ratings_count DESC, ratings_average DESC
LIMIT 10;
