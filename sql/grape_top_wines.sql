-- Global grape analysis.
-- Step 1: identify the top 3 most common grapes worldwide using the country
-- summary table most_used_grapes_per_country.
-- Step 2: because the schema does not provide a direct wine-to-grape bridge,
-- identify candidate wines by matching the grape name inside wine names.
-- This is a conservative approximation and avoids inventing nonexistent links.
-- Step 3: return the top 5 highest-rated wines for each top grape.

WITH top_grapes AS (
    SELECT
        g.id AS grape_id,
        g.name AS grape_name,
        SUM(m.wines_count) AS global_wines_count
    FROM most_used_grapes_per_country m
    JOIN grapes g
        ON g.id = m.grape_id
    GROUP BY g.id, g.name
    ORDER BY global_wines_count DESC
    LIMIT 3
),
grape_named_wines AS (
    SELECT
        tg.grape_name,
        w.id AS wine_id,
        w.name AS wine_name,
        c.name AS country_name,
        r.name AS region_name,
        w.ratings_average,
        w.ratings_count,
        ROW_NUMBER() OVER (
            PARTITION BY tg.grape_name
            ORDER BY w.ratings_average DESC, w.ratings_count DESC, w.name
        ) AS wine_rank_for_grape
    FROM top_grapes tg
    JOIN wines w
        ON w.name LIKE '%' || tg.grape_name || '%'
    JOIN regions r
        ON r.id = w.region_id
    JOIN countries c
        ON c.code = r.country_code
)
SELECT
    grape_name,
    wine_rank_for_grape,
    wine_id,
    wine_name,
    country_name,
    region_name,
    ratings_average,
    ratings_count
FROM grape_named_wines
WHERE wine_rank_for_grape <= 5
ORDER BY grape_name, wine_rank_for_grape;
