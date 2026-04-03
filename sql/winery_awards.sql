-- Three creative winery awards.
-- Important data note:
-- the schema's winery linkage is partial, so this query uses only wineries
-- that successfully match through wines.winery_id = wineries.id.
-- Award logic:
-- - Best Overall Winery: strongest combined quality signal
-- - People's Favorite Winery: highest audience approval by rating volume
-- - Hidden Gem Winery: high rating with below-average visibility

WITH winery_metrics AS (
    SELECT
        wr.id AS winery_id,
        wr.name AS winery_name,
        COUNT(DISTINCT w.id) AS matched_wines,
        ROUND(AVG(w.ratings_average), 3) AS avg_wine_rating,
        SUM(COALESCE(w.ratings_count, 0)) AS total_wine_ratings,
        ROUND(AVG(v.ratings_average), 3) AS avg_vintage_rating,
        SUM(COALESCE(v.ratings_count, 0)) AS total_vintage_ratings,
        COUNT(DISTINCT vtr.top_list_id) AS toplist_appearances
    FROM wines w
    JOIN wineries wr
        ON w.winery_id = wr.id
    LEFT JOIN vintages v
        ON v.wine_id = w.id
    LEFT JOIN vintage_toplists_rankings vtr
        ON vtr.vintage_id = v.id
    GROUP BY wr.id, wr.name
),
best_overall AS (
    SELECT
        'Best Overall Winery' AS award_category,
        winery_name,
        matched_wines,
        avg_wine_rating,
        total_wine_ratings,
        avg_vintage_rating,
        total_vintage_ratings,
        toplist_appearances,
        'Highest combined quality signal across matched wine and vintage records.' AS selection_reason,
        ROW_NUMBER() OVER (
            ORDER BY COALESCE(avg_vintage_rating, avg_wine_rating) DESC,
                     total_wine_ratings DESC,
                     winery_name
        ) AS rn
    FROM winery_metrics
),
peoples_favorite AS (
    SELECT
        'People''s Favorite Winery' AS award_category,
        winery_name,
        matched_wines,
        avg_wine_rating,
        total_wine_ratings,
        avg_vintage_rating,
        total_vintage_ratings,
        toplist_appearances,
        'Largest audience approval based on total wine rating volume.' AS selection_reason,
        ROW_NUMBER() OVER (
            ORDER BY total_wine_ratings DESC,
                     avg_wine_rating DESC,
                     winery_name
        ) AS rn
    FROM winery_metrics
),
hidden_gem AS (
    SELECT
        'Hidden Gem Winery' AS award_category,
        winery_name,
        matched_wines,
        avg_wine_rating,
        total_wine_ratings,
        avg_vintage_rating,
        total_vintage_ratings,
        toplist_appearances,
        'Strong quality with below-average rating volume, indicating upside potential.' AS selection_reason,
        ROW_NUMBER() OVER (
            ORDER BY avg_wine_rating DESC,
                     total_wine_ratings ASC,
                     winery_name
        ) AS rn
    FROM winery_metrics
    WHERE total_wine_ratings < (SELECT AVG(total_wine_ratings) FROM winery_metrics)
)
SELECT
    award_category,
    winery_name,
    matched_wines,
    avg_wine_rating,
    total_wine_ratings,
    avg_vintage_rating,
    total_vintage_ratings,
    toplist_appearances,
    selection_reason
FROM best_overall
WHERE rn = 1

UNION ALL

SELECT
    award_category,
    winery_name,
    matched_wines,
    avg_wine_rating,
    total_wine_ratings,
    avg_vintage_rating,
    total_vintage_ratings,
    toplist_appearances,
    selection_reason
FROM peoples_favorite
WHERE rn = 1

UNION ALL

SELECT
    award_category,
    winery_name,
    matched_wines,
    avg_wine_rating,
    total_wine_ratings,
    avg_vintage_rating,
    total_vintage_ratings,
    toplist_appearances,
    selection_reason
FROM hidden_gem
WHERE rn = 1;

