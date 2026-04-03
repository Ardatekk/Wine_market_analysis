-- Visualization-ready vintage leaderboard.
-- The dataset keeps one row per vintage and includes:
-- - quality through ratings_average
-- - popularity through ratings_count
-- - commercial value through price_euros
-- - prestige signal through toplist appearances
-- A small ratings floor removes very thin-sample vintages.

SELECT
    v.id AS vintage_id,
    v.name AS vintage_name,
    w.name AS wine_name,
    c.name AS country_name,
    v.year,
    v.ratings_average,
    v.ratings_count,
    v.price_euros,
    COUNT(DISTINCT vtr.top_list_id) AS toplist_appearances,
    MIN(vtr.rank) AS best_rank
FROM vintages v
JOIN wines w
    ON v.wine_id = w.id
JOIN regions r
    ON w.region_id = r.id
JOIN countries c
    ON r.country_code = c.code
LEFT JOIN vintage_toplists_rankings vtr
    ON vtr.vintage_id = v.id
WHERE v.ratings_count >= 25
GROUP BY v.id, v.name, w.name, c.name, v.year, v.ratings_average, v.ratings_count, v.price_euros
ORDER BY v.ratings_average DESC, v.ratings_count DESC, toplist_appearances DESC, v.price_euros DESC;
