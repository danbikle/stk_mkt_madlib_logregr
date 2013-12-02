--
-- ~/tv/qry_abrupt.sql
--

-- I use this script to look for abrupt changes in closing prices.
-- Sometimes they are due to stock splits.

-- Usually I get split dates off sites like Yahoo but this script
-- can be useful.

SELECT
tkr
,ydate
,closing_price
,ROUND(closing_price/cp_next_day,1) poss_split_ratio
,cp_next_day
,cp_next_day - closing_price AS price_delta
,100 * (cp_next_day - closing_price)/closing_price AS price_delta_pct
FROM
(
  SELECT
  tkr
  ,ydate
  ,closing_price
  ,LEAD(closing_price) OVER (PARTITION BY tkr ORDER BY ydate) AS cp_next_day
  FROM ydata
  WHERE closing_price > 0
) subq
-- Any price delta > 17 pct is suspicious:
WHERE ABS(100 * (cp_next_day - closing_price)/closing_price) > 17
ORDER BY tkr,ydate DESC
;
