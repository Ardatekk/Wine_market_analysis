-- Vivino analytical query set for SQLite
-- Generated from the live schema in data/vivino.db


PRAGMA table_info();

-- 1. Top wine-producing countries
SELECT code, name, wines_count, wineries_count, regions_count, users_count
FROM countries
ORDER BY wines_count DESC
LIMIT 10;

-- 2. Countries with the highest wine density per region
SELECT c.name AS country_name,
       ROUND(1.0 * c.wines_count / NULLIF(c.regions_count, 0), 2) AS wines_per_region,
       c.wines_count,
       c.regions_count
FROM countries c
WHERE c.regions_count > 0
ORDER BY wines_per_region DESC
LIMIT 10;

-- 3. Most common grapes across the dataset
SELECT g.name AS grape_name,
       SUM(m.wines_count) AS total_wines_using_grape,
       COUNT(DISTINCT m.country_code) AS countries_using_grape
FROM most_used_grapes_per_country m
JOIN grapes g ON m.grape_id = g.id
GROUP BY g.id, g.name
ORDER BY total_wines_using_grape DESC
LIMIT 10;

-- 4. Leading grape in each country
WITH ranked_grapes AS (
    SELECT c.name AS country_name,
           g.name AS grape_name,
           m.wines_count,
           ROW_NUMBER() OVER (
               PARTITION BY c.code
               ORDER BY m.wines_count DESC, g.name
           ) AS rn
    FROM most_used_grapes_per_country m
    JOIN countries c ON m.country_code = c.code
    JOIN grapes g ON m.grape_id = g.id
)
SELECT country_name, grape_name, wines_count
FROM ranked_grapes
WHERE rn = 1
ORDER BY wines_count DESC, country_name;

-- 5. Flavor group analysis
SELECT fg.name AS flavor_group,
       COUNT(DISTINCT kw.wine_id) AS wines_tagged,
       COUNT(*) AS keyword_rows,
       SUM(kw.count) AS total_keyword_mentions,
       ROUND(AVG(kw.count), 2) AS avg_mentions_per_keyword_row
FROM flavor_groups fg
LEFT JOIN keywords_wine kw
       ON kw.group_name = fg.name
GROUP BY fg.name
ORDER BY total_keyword_mentions DESC, flavor_group;

-- 6. Top 3 keywords inside each flavor group
WITH keyword_totals AS (
    SELECT kw.group_name,
           k.name AS keyword_name,
           SUM(kw.count) AS total_mentions,
           ROW_NUMBER() OVER (
               PARTITION BY kw.group_name
               ORDER BY SUM(kw.count) DESC, k.name
           ) AS rn
    FROM keywords_wine kw
    JOIN keywords k ON kw.keyword_id = k.id
    GROUP BY kw.group_name, k.id, k.name
)
SELECT group_name, keyword_name, total_mentions
FROM keyword_totals
WHERE rn <= 3
ORDER BY group_name, total_mentions DESC, keyword_name;

-- 7. Region-based breakdown of ratings and prices
SELECT c.name AS country_name,
       r.name AS region_name,
       COUNT(DISTINCT w.id) AS wine_count,
       ROUND(AVG(w.ratings_average), 3) AS avg_wine_rating,
       ROUND(AVG(v.price_euros), 2) AS avg_vintage_price_eur,
       COUNT(DISTINCT v.id) AS vintage_count
FROM wines w
JOIN regions r ON w.region_id = r.id
JOIN countries c ON r.country_code = c.code
JOIN vintages v ON v.wine_id = w.id
GROUP BY c.code, c.name, r.id, r.name
HAVING COUNT(DISTINCT w.id) >= 5
ORDER BY avg_wine_rating DESC, wine_count DESC
LIMIT 15;

-- 8. Natural wine share by country
SELECT c.name AS country_name,
       COUNT(*) AS wine_count,
       SUM(CASE WHEN w.is_natural = 1 THEN 1 ELSE 0 END) AS natural_wine_count,
       ROUND(100.0 * SUM(CASE WHEN w.is_natural = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS natural_share_pct,
       ROUND(AVG(w.ratings_average), 3) AS avg_rating
FROM wines w
JOIN regions r ON w.region_id = r.id
JOIN countries c ON r.country_code = c.code
GROUP BY c.code, c.name
ORDER BY natural_share_pct DESC, wine_count DESC;

-- 9. Toplist performance overview
SELECT t.name AS toplist_name,
       c.name AS toplist_country,
       COUNT(*) AS ranked_vintages,
       ROUND(AVG(v.ratings_average), 3) AS avg_ranked_vintage_rating,
       ROUND(AVG(v.price_euros), 2) AS avg_ranked_vintage_price_eur,
       MIN(vtr.rank) AS best_rank_in_list
FROM vintage_toplists_rankings vtr
JOIN toplists t ON vtr.top_list_id = t.id
LEFT JOIN countries c ON t.country_code = c.code
JOIN vintages v ON vtr.vintage_id = v.id
GROUP BY t.id, t.name, c.name
ORDER BY ranked_vintages DESC, avg_ranked_vintage_rating DESC
LIMIT 15;

-- 10. Biggest ranking improvements
SELECT v.name AS vintage_name,
       w.name AS wine_name,
       c.name AS country_name,
       t.name AS toplist_name,
       vtr.previous_rank,
       vtr.rank,
       (vtr.previous_rank - vtr.rank) AS rank_improvement
FROM vintage_toplists_rankings vtr
JOIN vintages v ON vtr.vintage_id = v.id
JOIN wines w ON v.wine_id = w.id
JOIN regions r ON w.region_id = r.id
JOIN countries c ON r.country_code = c.code
JOIN toplists t ON vtr.top_list_id = t.id
WHERE vtr.previous_rank IS NOT NULL
  AND vtr.rank IS NOT NULL
  AND vtr.previous_rank > vtr.rank
ORDER BY rank_improvement DESC, vtr.rank ASC, v.ratings_average DESC
LIMIT 15;
