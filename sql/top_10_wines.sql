-- Top 10 wines by business relevance.
-- WHY these wines are selected:
-- A wine that is only popular is not always the strongest premium candidate,
-- and a wine that is only highly rated may have too little market traction.
-- This ranking therefore combines:
-- 1. ratings_count as a proxy for popularity and market validation
-- 2. ratings_average as a proxy for perceived quality
-- The ORDER BY gives priority to large audience approval first, then uses
-- rating quality as the tie-breaker so the result surfaces wines that are
-- both widely known and well reviewed.
-- The query joins wines to regions and countries so the output also includes
-- geographic context for commercial reporting.

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
 