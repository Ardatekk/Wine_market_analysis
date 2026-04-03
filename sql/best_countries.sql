-- Best countries by average sampled wine quality.
-- countries gives reported market size, while regions and wines
-- provide the sampled wine records available in this database.
-- The HAVING clause avoids tiny country samples.

SELECT
    c.code,
    c.name AS country_name,
    c.wines_count AS reported_wines_count,
    COUNT(w.id) AS sampled_wines,
    ROUND(AVG(w.ratings_average), 3) AS avg_wine_rating,
    ROUND(AVG(w.ratings_count), 1) AS avg_rating_volume,
    ROUND(1.0 * c.wines_count / NULLIF(c.regions_count, 0), 2) AS wines_per_region
FROM countries c
LEFT JOIN regions r
    ON r.country_code = c.code
LEFT JOIN wines w
    ON w.region_id = r.id
GROUP BY c.code, c.name, c.wines_count, c.regions_count
HAVING COUNT(w.id) >= 5
ORDER BY avg_wine_rating DESC, sampled_wines DESC
LIMIT 10;
