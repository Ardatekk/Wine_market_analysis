-- Top wines by popularity.
-- Popularity is measured with ratings_count.
-- The query joins wines to regions and countries so the result
-- includes location context for each wine.

SELECT
    w.id,
    w.name AS wine_name,
    c.name AS country_name,
    r.name AS region_name,
    w.ratings_average,
    w.ratings_count,
    w.is_natural
FROM wines w
JOIN regions r
    ON w.region_id = r.id
JOIN countries c
    ON r.country_code = c.code
ORDER BY w.ratings_count DESC, w.ratings_average DESC
LIMIT 10;
