# Vivino Market Analysis

## Project Overview

This project turns `data/vivino.db` into a business-ready market analysis for wine sales, marketing prioritization, customer taste discovery, and leaderboard visualization.

The SQL is SQLite-compatible and uses only real columns from the live schema.

## Core Deliverables

- `sql/top_10_sales_wines.sql`
- `sql/country_marketing_priority.sql`
- `sql/winery_awards.sql`
- `sql/keyword_cluster_analysis.sql`
- `sql/grape_top_wines.sql`
- `sql/country_leaderboard.sql`
- `sql/vintage_leaderboard.sql`

## How The Analysis Works

### 1. 10 Wines For Sales

`sql/top_10_sales_wines.sql` builds a final shortlist of 10 wines using a balanced commercial score.

The score combines:

- `ratings_count` as a proxy for market traction
- `ratings_average` as a proxy for quality perception

This avoids a weak shortlist built only from niche luxury wines or only from mass-market wines.

### 2. Country Marketing Priority

`sql/country_marketing_priority.sql` ranks countries for marketing investment using:

- average wine rating
- total wine assortment (`wines_count`)
- market engagement (`users_count`)

The weighted model makes the output actionable for budget planning rather than descriptive only.

### 3. Winery Awards

`sql/winery_awards.sql` produces three award categories:

- Best Overall Winery
- People's Favorite Winery
- Hidden Gem Winery

The logic uses matched winery, wine, vintage, and ranking signals where the schema permits.

### 4. Keyword Cluster Analysis

`sql/keyword_cluster_analysis.sql` finds wines that match all five required taste signals:

- `coffee`
- `toast`
- `green apple`
- `cream`
- `citrus`

The query is case-sensitive and only keeps keywords with more than 10 confirmations.

### 5. Global Grape Analysis

`sql/grape_top_wines.sql` identifies the top 3 grapes worldwide and returns the top rated wines for each.

Because the schema does not include a direct wine-to-grape table, this analysis uses grape-name matching inside wine names after identifying the top grapes from the country-grape summary table.

### 6. Leaderboards For Visualization

`sql/country_leaderboard.sql` and `sql/vintage_leaderboard.sql` produce flat analytical tables designed for Streamlit charts or Python plotting.

## Key Findings

- France, Italy, and the United States dominate total wine volume, but they do not contribute equally across quality, engagement, and sales-readiness.
- The sales shortlist is not driven by popularity alone. Wines such as `Unico`, `Sauternes`, `Special Selection Cabernet Sauvignon`, and `Sassicaia` rise because they combine high rating strength with substantial review volume.
- The United States emerges as the strongest marketing-budget candidate because it combines the highest engagement base with a strong average rating and a large wine assortment.
- France remains strategically critical because it pairs the largest wine catalog with strong ratings and large absolute demand signals.
- Spain contributes several strong sales candidates, which suggests premium opportunity even if its total scale is smaller than France or the United States.

## Market Strategy Insights

- Use the United States as the lead demand-capture market for acquisition-focused campaigns because user engagement is far ahead of other countries.
- Use France as the broad portfolio storytelling market because it combines assortment depth with many high-performing wines and strong sparkling flavor clusters.
- Use Italy as a premium craftsmanship market, especially for prestige-led campaigns where brand narrative and quality reputation matter more than pure volume.
- Use Spain as a selective premium-growth market, focusing on highly rated flagship wines rather than broad catalog expansion.

## Consumer Taste Clusters

- The strict five-keyword cluster points toward wines with layered freshness plus richness: `citrus` and `green apple` signal freshness, while `toast`, `cream`, and `coffee` signal texture and maturation.
- This cluster is heavily concentrated in Champagne-style wines, which implies a premium consumer segment that values complexity rather than simple fruit-forward profiles.
- These wines are commercially interesting because they combine strong taste identity with high user confirmation counts.

## Country Comparison

- The United States wins on engagement and commercial momentum.
- France wins on catalog depth and overall presence.
- Italy remains one of the strongest premium countries, but its marketing case is more prestige-oriented than engagement-led.
- Germany shows strong average rating performance, but its much smaller commercial base makes it more suitable for targeted campaigns than broad budget deployment.

## Wine Quality Vs Popularity

- High quality alone is not enough for a sales shortlist; low-volume prestige wines may be excellent but harder to scale.
- High popularity alone is also not enough; the shortlist should protect brand quality by requiring strong ratings.
- The balanced-scoring model helps identify wines that are both trusted and scalable, which is the most practical combination for commercial sales planning.

## Winery Awards Reasoning

- Best Overall Winery goes to the matched winery with the strongest combined quality profile across its linked wine and vintage records.
- People's Favorite Winery goes to the matched winery with the largest audience approval based on ratings volume.
- Hidden Gem Winery goes to a high-rated winery with below-average visibility, making it a good candidate for niche promotion or discovery campaigns.

These awards are useful as internal storytelling tools, but they should be interpreted carefully because the winery linkage in the raw data is incomplete.

## Limitations

- There is no direct wine-to-grape relationship in the schema, so grape-level wine selection is necessarily approximate.
- The winery relationship is only partially reliable because `wines.winery_id` does not consistently resolve to `wineries.id`.
- Some country-level tables are summary tables, while `wines` and `vintages` are sample-level tables, so reported totals and sampled counts should not be treated as identical.
