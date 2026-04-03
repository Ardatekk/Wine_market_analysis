-- Visualization-ready country leaderboard.
-- Intended for Streamlit or plotting workflows.
-- This output blends market size, engagement, and wine quality into one clean
-- country-level dataset with one row per country.
-- Countries with at least 5 sampled wines are kept for more stable averages.

SELECT
    c.code,
    c.name AS country_name,
    c.wines_count AS reported_wines_count,
    c.regions_count,
    c.users_count,
    COUNT(DISTINCT w.id) AS sampled_wines,
    ROUND(AVG(w.ratings_average), 3) AS avg_wine_rating,
    ROUND(AVG(w.ratings_count), 1) AS avg_rating_count,
    ROUND(AVG(v.price_euros), 2) AS avg_vintage_price_eur,
    ROUND(1.0 * c.wines_count / NULLIF(c.regions_count, 0), 2) AS wines_per_region
FROM countries c
LEFT JOIN regions r
    ON r.country_code = c.code
LEFT JOIN wines w
    ON w.region_id = r.id
LEFT JOIN vintages v
    ON v.wine_id = w.id
GROUP BY c.code, c.name, c.wines_count, c.regions_count, c.users_count
HAVING COUNT(DISTINCT w.id) >= 5
ORDER BY avg_wine_rating DESC, sampled_wines DESC, reported_wines_count DESC;
