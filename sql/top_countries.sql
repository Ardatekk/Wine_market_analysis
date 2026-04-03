-- Top countries by reported wine volume.
-- This query uses the aggregated country summary table directly,
-- so no JOIN is needed.

SELECT
    code,
    name,
    wines_count,
    wineries_count,
    regions_count,
    users_count
FROM countries
ORDER BY wines_count DESC
LIMIT 10;
