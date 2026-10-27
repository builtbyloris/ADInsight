-- KPI totali K01 K02 K03 K04 K05 K06 K07.
SELECT SUM(units_sold) AS units_sold,
       SUM(total_sales) AS revenue_usd,
       SUM(operating_profit) AS operating_profit_usd,
       ROUND((100 * SUM(operating_profit)::numeric / NULLIF(SUM(total_sales)::numeric, 0)), 2) AS operating_margin_pct,
       ROUND(AVG(price_per_unit)::numeric, 2) AS avg_recorded_price_usd,
       ROUND((SUM(total_sales)::numeric / NULLIF(SUM(units_sold), 0)), 2) AS realized_price_usd,
       ROUND((SUM(operating_profit)::numeric / NULLIF(SUM(units_sold), 0)), 2) AS profit_per_unit_usd
FROM adidas_sales_features;

-- Supplementary analytical query: ranking retailer, volume, fatturato, profitto e margine.
SELECT retailer,
       SUM(units_sold) AS units_sold,
       SUM(total_sales) AS revenue_usd,
       SUM(operating_profit) AS operating_profit_usd,
       ROUND(100 * SUM(operating_profit)::numeric / NULLIF(SUM(total_sales)::numeric, 0), 2) AS operating_margin_pct,
       ROUND(100 * SUM(units_sold)::numeric / NULLIF(SUM(SUM(units_sold)) OVER (), 0), 2) AS unit_share_pct,
       ROUND(100 * SUM(total_sales)::numeric / NULLIF(SUM(SUM(total_sales)) OVER ()::numeric, 0), 2) AS revenue_share_pct
FROM adidas_sales_features
GROUP BY retailer
ORDER BY units_sold DESC;

-- Supplementary analytical query: ranking del prodotto più venduto per retailer, incluse eventuali parità.
WITH t AS (
  SELECT retailer, product, SUM(units_sold) AS units_sold
  FROM adidas_sales_features
  GROUP BY retailer, product
), ranked AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY retailer ORDER BY units_sold DESC) AS product_rank
  FROM t
)
SELECT retailer, product, units_sold FROM ranked
WHERE product_rank = 1 ORDER BY retailer, product;

-- Supplementary analytical query: canalizzazione delle unità per retailer.
SELECT retailer, sales_method,
       SUM(units_sold) AS units_sold,
       ROUND(100 * SUM(units_sold)::numeric /
             NULLIF(SUM(SUM(units_sold)) OVER (PARTITION BY retailer), 0), 2) AS retailer_unit_share_pct
FROM adidas_sales_features
GROUP BY retailer, sales_method
ORDER BY retailer, units_sold DESC;

-- Supplementary analytical query: copertura commerciale per mese/retailer, per confronti omogenei.
SELECT retailer, DATE_TRUNC('month', invoice_date)::date AS month,
       COUNT(*) AS records,
       COUNT(DISTINCT invoice_date) AS observed_dates,
       COUNT(DISTINCT state) AS represented_states,
       SUM(units_sold) AS units_sold
FROM adidas_sales_features
GROUP BY retailer, DATE_TRUNC('month', invoice_date)::date
ORDER BY retailer, month;

-- Supplementary analytical query: tipologie e margini correttamente ponderati.
SELECT product,
       SUM(units_sold) AS units_sold,
       SUM(total_sales) AS revenue_usd,
       SUM(operating_profit) AS operating_profit_usd,
       ROUND(100 * SUM(operating_profit)::numeric / NULLIF(SUM(total_sales)::numeric, 0), 2) AS operating_margin_pct
FROM adidas_sales_features
GROUP BY product
ORDER BY units_sold DESC;

-- Supplementary analytical query: tipologia principale per regione (con eventuali parità).
WITH t AS (
  SELECT region, product, SUM(units_sold) AS units_sold
  FROM adidas_sales_features GROUP BY region, product
), ranked AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY region ORDER BY units_sold DESC) AS rnk
  FROM t
)
SELECT region, product, units_sold FROM ranked WHERE rnk = 1 ORDER BY region, product;

-- Supplementary analytical query: target merceologico, prezzo medio semplice e realizzato.
SELECT product_gender,
       SUM(units_sold) AS units_sold,
       SUM(total_sales) AS revenue_usd,
       ROUND(AVG(price_per_unit)::numeric, 2) AS avg_recorded_price_usd,
       ROUND(SUM(total_sales)::numeric / NULLIF(SUM(units_sold), 0), 2) AS realized_price_usd
FROM adidas_sales_features
GROUP BY product_gender
ORDER BY units_sold DESC;
