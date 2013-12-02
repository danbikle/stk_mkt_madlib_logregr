\set ECHO all
--
-- ~/tv/qry_predictions12.sql
--

SELECT 
COUNT(tkr)                     ccount
,ROUND(AVG(ng3),4)             avg_ng3
,ROUND(SUM(ng3),4)             sum_ng3
,ROUND(AVG(ng3)/STDDEV(ng3),4) sharpe_r 
FROM predictions12 
WHERE prob<0.45
;

SELECT 
COUNT(tkr)                     ccount
,ROUND(AVG(ng3),4)             avg_ng3
,ROUND(SUM(ng3),4)             sum_ng3
,ROUND(AVG(ng3)/STDDEV(ng3),4) sharpe_r 
FROM predictions12 
WHERE prob>0.55
;

-- Look at Bearish predictions:
SELECT 
tkr
,COUNT(tkr)                    ccount
,ROUND(AVG(ng3),4)             avg_ng3
,ROUND(SUM(ng3),4)             sum_ng3
,ROUND(AVG(ng3)/STDDEV(ng3),4) sharpe_r 
FROM predictions12 
WHERE prob<0.45 
GROUP BY tkr 
HAVING COUNT(tkr) > 9 
ORDER BY SUM(ng3)
;

-- Look at Bullish predictions:
SELECT 
tkr
,COUNT(tkr)                    ccount
,ROUND(AVG(ng3),4)             avg_ng3
,ROUND(SUM(ng3),4)             sum_ng3
,ROUND(AVG(ng3)/STDDEV(ng3),4) sharpe_r 
FROM predictions12 
WHERE prob>0.55
GROUP BY tkr 
HAVING COUNT(tkr) > 9 
ORDER BY SUM(ng3)
;

-- Classic Accuracy Calculation.
-- True Positives + True Negatives here:
SELECT 
COUNT(tkr) ccount 
FROM predictions12 
WHERE SIGN(prob-0.5) = SIGN(ng3)
;

-- All observations
SELECT COUNT(tkr) FROM predictions12;

-- Accuracy is Count(True Positives) + Count(True Negatives) / Count(All observations)
-- Usually it is near 50%.

-- Confusion Matrix Calculations.

-- True Positives:
SELECT COUNT(tkr) ccount FROM predictions12 WHERE prob>0.5 AND ng3>0;

-- True Negatives:
SELECT COUNT(tkr) ccount FROM predictions12 WHERE prob<0.5 AND ng3<0;

-- False Positives:
SELECT COUNT(tkr) ccount FROM predictions12 WHERE prob>0.5 AND ng3<0;

-- False Negatives:
SELECT COUNT(tkr) ccount FROM predictions12 WHERE prob<0.5 AND ng3>0;

-- end
