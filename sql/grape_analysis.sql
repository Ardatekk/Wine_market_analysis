-- Top 3 most used grapes and the top 5 best-rated wines for each grape.
-- The schema has no direct wine-to-grape mapping.
-- This query uses most_used_grapes_per_country to find the top grapes,
-- then looks at wines from countries where each grape appears in that summary.
-- In other words, grape-to-wine mapping here is an approximation driven by
-- country-level grape prevalence, not a confirmed grape assignment per wine.
-- ROW_NUMBER keeps only the top 5 wines per grape.

WITH top_grapes AS (
    SELECT
        g.id AS grape_id,
        g.name AS grape_name,
        SUM(m.wines_count) AS total_wines_using_grape
    FROM most_used_grapes_per_country m
    JOIN grapes g
        ON m.grape_id = g.id
    GROUP BY g.id, g.name
    ORDER BY total_wines_using_grape DESC
    LIMIT 3
),
ranked_wines AS (
    SELECT
        tg.grape_name,
        c.name AS country_name,
        r.name AS region_name,
        w.id AS wine_id,
        w.name AS wine_name,
        w.ratings_average,
        w.ratings_count,
        ROW_NUMBER() OVER (
            PARTITION BY tg.grape_name
            ORDER BY w.ratings_average DESC, w.ratings_count DESC, w.name
        ) AS rn
    FROM top_grapes tg
    JOIN most_used_grapes_per_country m
        ON m.grape_id = tg.grape_id
    JOIN countries c
        ON m.country_code = c.code
    JOIN regions r
        ON r.country_code = c.code
    JOIN wines w
        ON w.region_id = r.id
)
SELECT
    grape_name,
    country_name,
    region_name,
    wine_id,
    wine_name,
    ratings_average,
    ratings_count
FROM ranked_wines
WHERE rn <= 5
ORDER BY grape_name, rn;
