--
-- ~/tv/cr_logreg_vectors.sql
--

-- I use this script to do Logistic Regression.

-- I get boundry date for model from cmd-line.

-- Here is doc about Logistic Regression:
-- http://doc.madlib.net/latest/group__grp__logreg.html

-- I start by creating vector-element values,
-- in this order:

-- tv10:
-- tkr            this is stock symbol AKA ticker AKA tkr
-- ,ydate         this is observation date for tkr
-- ,cp            this is Short name for closing_price (split adjusted)
-- ,ng1 through 5 this is normalized gain for 1,2,3,4,5 days
-- ma2, ... 200   this is moving average of closing_price over 2,3,... 200 days

-- tv12:
-- y1,...5                              this is 1 if ng1,2,3,4,5 > 0 else this is 0.
-- ,ma2,3,...,200slope                  this is slope of moving average
-- ,(cp - ma2,3,4,5,9,20,40,80,200)/cp  this is calclulation of closing_price and moving average
-- ,(ma2 - ma3,4,5,9,20,40,80,200)/ma2  these are moving average calclulations:
-- ,(ma3 - ma4,5,9,20,40,80,200)/ma3
-- ,(ma4 - ma5,9,20,40,80,200)/ma4
-- ,(ma5 - ma9,20,40,80,200)/ma5
-- ,(ma9 - ma20,40,80,200)/ma9
-- ,(ma9 - ma20,40,80,200)/ma9
-- ,(ma20 - ma40,80,200)/ma20
-- ,(ma40 - ma80,200)/ma40
-- ,(ma80 - ma200)/ma80

-- tv14:
-- ,ma2,3,...,200slope_delta     this is rate of change of moving average slope

-- Much of this technique depends on window functions.
-- In Oracle window functions are often called analytic functions.
-- http://www.postgresql.org/docs/9.2/static/functions-window.html
-- http://docs.oracle.com/cd/E11882_01/server.112/e17118/functions004.htm#SQLRF06174
-- https://www.google.com/search?q=sql+window+functions

DROP   TABLE IF EXISTS tv10;
CREATE TABLE tv10 AS
SELECT
tkr,ydate
,closing_price cp
,(LEAD(closing_price,1,NULL) OVER (PARTITION BY TKR ORDER BY ydate) - closing_price)/closing_price  ng1
,(LEAD(closing_price,2,NULL) OVER (PARTITION BY TKR ORDER BY ydate) - closing_price)/closing_price  ng2
,(LEAD(closing_price,3,NULL) OVER (PARTITION BY TKR ORDER BY ydate) - closing_price)/closing_price  ng3
,(LEAD(closing_price,4,NULL) OVER (PARTITION BY TKR ORDER BY ydate) - closing_price)/closing_price  ng4
,(LEAD(closing_price,5,NULL) OVER (PARTITION BY TKR ORDER BY ydate) - closing_price)/closing_price  ng5
,AVG(closing_price)OVER(PARTITION BY TKR ORDER BY ydate ROWS BETWEEN 2 PRECEDING AND 0 PRECEDING)   ma02
,AVG(closing_price)OVER(PARTITION BY TKR ORDER BY ydate ROWS BETWEEN 3 PRECEDING AND 0 PRECEDING)   ma03
,AVG(closing_price)OVER(PARTITION BY TKR ORDER BY ydate ROWS BETWEEN 4 PRECEDING AND 0 PRECEDING)   ma04
,AVG(closing_price)OVER(PARTITION BY TKR ORDER BY ydate ROWS BETWEEN 5 PRECEDING AND 0 PRECEDING)   ma05
,AVG(closing_price)OVER(PARTITION BY TKR ORDER BY ydate ROWS BETWEEN 9 PRECEDING AND 0 PRECEDING)   ma09
,AVG(closing_price)OVER(PARTITION BY TKR ORDER BY ydate ROWS BETWEEN 20 PRECEDING AND 0 PRECEDING)  ma20
,AVG(closing_price)OVER(PARTITION BY TKR ORDER BY ydate ROWS BETWEEN 40 PRECEDING AND 0 PRECEDING)  ma40
,AVG(closing_price)OVER(PARTITION BY TKR ORDER BY ydate ROWS BETWEEN 80 PRECEDING AND 0 PRECEDING)  ma80
,AVG(closing_price)OVER(PARTITION BY TKR ORDER BY ydate ROWS BETWEEN 200 PRECEDING AND 0 PRECEDING) ma200
FROM ydata
ORDER BY ydate
;

DROP   TABLE IF EXISTS tv12;
CREATE TABLE tv12 AS
SELECT
tkr,ydate
,ng1
,ng2
,ng3
,ng4
,ng5
,CASE WHEN ng1>0 THEN 1 ELSE 0 END y1
,CASE WHEN ng2>0 THEN 1 ELSE 0 END y2
,CASE WHEN ng3>0 THEN 1 ELSE 0 END y3
,CASE WHEN ng4>0 THEN 1 ELSE 0 END y4
,CASE WHEN ng5>0 THEN 1 ELSE 0 END y5
,(ma02-LAG(ma02,1,ma02) OVER (PARTITION BY TKR ORDER BY ydate))/ma02     ma02s
,(ma03-LAG(ma03,1,ma03) OVER (PARTITION BY TKR ORDER BY ydate))/ma03     ma03s
,(ma04-LAG(ma04,1,ma04) OVER (PARTITION BY TKR ORDER BY ydate))/ma04     ma04s
,(ma05-LAG(ma05,2,ma05) OVER (PARTITION BY TKR ORDER BY ydate))/ma05     ma05s
,(ma09-LAG(ma09,3,ma09) OVER (PARTITION BY TKR ORDER BY ydate))/ma09     ma09s
,(ma20-LAG(ma20,4,ma20) OVER (PARTITION BY TKR ORDER BY ydate))/ma20     ma20s
,(ma40-LAG(ma40,5,ma40) OVER (PARTITION BY TKR ORDER BY ydate))/ma40     ma40s
,(ma80-LAG(ma80,6,ma80) OVER (PARTITION BY TKR ORDER BY ydate))/ma80     ma80s
,(ma200-LAG(ma200,7,ma200) OVER (PARTITION BY TKR ORDER BY ydate))/ma200 ma200s
,(cp - ma02)/cp      d0102 
,(cp - ma03)/cp      d0103 
,(cp - ma04)/cp      d0104 
,(cp - ma05)/cp      d0105 
,(cp - ma09)/cp      d0109 
,(cp - ma20)/cp      d0120 
,(cp - ma40)/cp      d0140 
,(cp - ma80)/cp      d0180 
,(cp - ma200)/cp     d01200
,(ma02 - ma03)/ma02  d0203
,(ma02 - ma04)/ma02  d0204
,(ma02 - ma05)/ma02  d0205
,(ma02 - ma09)/ma02  d0209
,(ma02 - ma20)/ma02  d0220
,(ma02 - ma40)/ma02  d0240
,(ma02 - ma80)/ma02  d0280
,(ma02 - ma200)/ma02 d02200
,(ma03 - ma04)/ma03  d0304
,(ma03 - ma05)/ma03  d0305
,(ma03 - ma09)/ma03  d0309
,(ma03 - ma20)/ma03  d0320
,(ma03 - ma40)/ma03  d0340
,(ma03 - ma80)/ma03  d0380
,(ma03 - ma200)/ma03 d03200
,(ma04 - ma05)/ma04  d0405
,(ma04 - ma09)/ma04  d0409
,(ma04 - ma20)/ma04  d0420
,(ma04 - ma40)/ma04  d0440
,(ma04 - ma80)/ma04  d0480
,(ma04 - ma200)/ma04 d04200
,(ma05 - ma09)/ma05  d0509
,(ma05 - ma20)/ma05  d0520
,(ma05 - ma40)/ma05  d0540
,(ma05 - ma80)/ma05  d0580
,(ma05 - ma200)/ma05 d05200
,(ma09 - ma20)/ma09  d0920
,(ma09 - ma40)/ma09  d0940
,(ma09 - ma80)/ma09  d0980
,(ma09 - ma200)/ma09 d09200
,(ma20 - ma40)/ma20  d2040
,(ma20 - ma80)/ma20  d2080
,(ma20 - ma200)/ma20 d20200
,(ma40 - ma80)/ma40  d4080
,(ma40 - ma200)/ma40 d40200
,(ma80 - ma200)/ma80 d80200
FROM tv10
ORDER BY ydate
;

DROP   TABLE IF EXISTS tv14;
CREATE TABLE tv14 AS
SELECT
tkr,ydate
,ng1
,ng2
,ng3
,ng4
,ng5
,y1
,y2
,y3
,y4
,y5
,ma02s
,ma03s
,ma04s
,ma05s
,ma09s
,ma20s
,ma40s
,ma80s
,ma200s
,d0102 
,d0103 
,d0104 
,d0105 
,d0109 
,d0120 
,d0140 
,d0180 
,d01200
,d0203
,d0204
,d0205
,d0209
,d0220
,d0240
,d0280
,d02200
,d0304
,d0305
,d0309
,d0320
,d0340
,d0380
,d03200
,d0405
,d0409
,d0420
,d0440
,d0480
,d04200
,d0509
,d0520
,d0540
,d0580
,d05200
,d0920
,d0940
,d0980
,d09200
,d2040
,d2080
,d20200
,d4080
,d40200
,d80200
,(ma02s-LAG(ma02s,1,ma02s) OVER (PARTITION BY TKR ORDER BY ydate)) ma02sd
,(ma03s-LAG(ma03s,1,ma03s) OVER (PARTITION BY TKR ORDER BY ydate)) ma03sd
,(ma04s-LAG(ma04s,1,ma04s) OVER (PARTITION BY TKR ORDER BY ydate)) ma04sd
,(ma05s-LAG(ma05s,2,ma05s) OVER (PARTITION BY TKR ORDER BY ydate)) ma05sd
,(ma09s-LAG(ma09s,3,ma09s) OVER (PARTITION BY TKR ORDER BY ydate)) ma09sd
,(ma20s-LAG(ma20s,4,ma20s) OVER (PARTITION BY TKR ORDER BY ydate)) ma20sd
,(ma40s-LAG(ma40s,6,ma40s) OVER (PARTITION BY TKR ORDER BY ydate)) ma40sd
,(ma80s-LAG(ma80s,8,ma80s) OVER (PARTITION BY TKR ORDER BY ydate)) ma80sd
,(ma200s-LAG(ma200s,20,ma200s) OVER (PARTITION BY TKR ORDER BY ydate)) ma200sd
FROM tv12
ORDER BY ydate
;


DROP   TABLE IF EXISTS tv14st;
CREATE TABLE tv14st AS
SELECT
tkr,ydate
,ng1
,ng2
,ng3
,ng4
,ng5
,y1
,y2
,y3
,y4
,y5
,ma02s
,ma03s
,ma04s
,ma05s
,ma09s
,ma20s
,ma40s
,ma80s
,ma200s
,d0102 
,d0103 
,d0104 
,d0105 
,d0109 
,d0120 
,d0140 
,d0180 
,d01200
,d0203
,d0204
,d0205
,d0209
,d0220
,d0240
,d0280
,d02200
,d0304
,d0305
,d0309
,d0320
,d0340
,d0380
,d03200
,d0405
,d0409
,d0420
,d0440
,d0480
,d04200
,d0509
,d0520
,d0540
,d0580
,d05200
,d0920
,d0940
,d0980
,d09200
,d2040
,d2080
,d20200
,d4080
,d40200
,d80200
,ma02sd
,ma03sd
,ma04sd
,ma05sd
,ma09sd
,ma20sd
,ma40sd
,ma80sd
,ma200sd
,1.0*STDDEV(ma02s  )OVER() ma02s_st
,1.0*STDDEV(ma03s  )OVER() ma03s_st
,1.0*STDDEV(ma04s  )OVER() ma04s_st
,1.0*STDDEV(ma05s  )OVER() ma05s_st
,1.0*STDDEV(ma09s  )OVER() ma09s_st
,1.0*STDDEV(ma20s  )OVER() ma20s_st
,1.0*STDDEV(ma40s  )OVER() ma40s_st
,1.0*STDDEV(ma80s  )OVER() ma80s_st
,1.0*STDDEV(ma200s )OVER() ma200s_st
,1.0*STDDEV(d0102  )OVER() d0102_st
,1.0*STDDEV(d0103  )OVER() d0103_st
,1.0*STDDEV(d0104  )OVER() d0104_st
,1.0*STDDEV(d0105  )OVER() d0105_st
,1.0*STDDEV(d0109  )OVER() d0109_st
,1.0*STDDEV(d0120  )OVER() d0120_st
,1.0*STDDEV(d0140  )OVER() d0140_st
,1.0*STDDEV(d0180  )OVER() d0180_st
,1.0*STDDEV(d01200 )OVER() d01200_st
,1.0*STDDEV(d0203  )OVER() d0203_st
,1.0*STDDEV(d0204  )OVER() d0204_st
,1.0*STDDEV(d0205  )OVER() d0205_st
,1.0*STDDEV(d0209  )OVER() d0209_st
,1.0*STDDEV(d0220  )OVER() d0220_st
,1.0*STDDEV(d0240  )OVER() d0240_st
,1.0*STDDEV(d0280  )OVER() d0280_st
,1.0*STDDEV(d02200 )OVER() d02200_st
,1.0*STDDEV(d0304  )OVER() d0304_st
,1.0*STDDEV(d0305  )OVER() d0305_st
,1.0*STDDEV(d0309  )OVER() d0309_st
,1.0*STDDEV(d0320  )OVER() d0320_st
,1.0*STDDEV(d0340  )OVER() d0340_st
,1.0*STDDEV(d0380  )OVER() d0380_st
,1.0*STDDEV(d03200 )OVER() d03200_st
,1.0*STDDEV(d0405  )OVER() d0405_st
,1.0*STDDEV(d0409  )OVER() d0409_st
,1.0*STDDEV(d0420  )OVER() d0420_st
,1.0*STDDEV(d0440  )OVER() d0440_st
,1.0*STDDEV(d0480  )OVER() d0480_st
,1.0*STDDEV(d04200 )OVER() d04200_st
,1.0*STDDEV(d0509  )OVER() d0509_st
,1.0*STDDEV(d0520  )OVER() d0520_st
,1.0*STDDEV(d0540  )OVER() d0540_st
,1.0*STDDEV(d0580  )OVER() d0580_st
,1.0*STDDEV(d05200 )OVER() d05200_st
,1.0*STDDEV(d0920  )OVER() d0920_st
,1.0*STDDEV(d0940  )OVER() d0940_st
,1.0*STDDEV(d0980  )OVER() d0980_st
,1.0*STDDEV(d09200 )OVER() d09200_st
,1.0*STDDEV(d2040  )OVER() d2040_st
,1.0*STDDEV(d2080  )OVER() d2080_st
,1.0*STDDEV(d20200 )OVER() d20200_st
,1.0*STDDEV(d4080  )OVER() d4080_st
,1.0*STDDEV(d40200 )OVER() d40200_st
,1.0*STDDEV(d80200 )OVER() d80200_st
,1.0*STDDEV(ma02sd )OVER() ma02sd_st
,1.0*STDDEV(ma03sd )OVER() ma03sd_st
,1.0*STDDEV(ma04sd )OVER() ma04sd_st
,1.0*STDDEV(ma05sd )OVER() ma05sd_st
,1.0*STDDEV(ma09sd )OVER() ma09sd_st
,1.0*STDDEV(ma20sd )OVER() ma20sd_st
,1.0*STDDEV(ma40sd )OVER() ma40sd_st
,1.0*STDDEV(ma80sd )OVER() ma80sd_st
,1.0*STDDEV(ma200sd )OVER() ma200sd_st
,AVG(ma02s  )OVER() ma02s_av
,AVG(ma03s  )OVER() ma03s_av
,AVG(ma04s  )OVER() ma04s_av
,AVG(ma05s  )OVER() ma05s_av
,AVG(ma09s  )OVER() ma09s_av
,AVG(ma20s  )OVER() ma20s_av
,AVG(ma40s  )OVER() ma40s_av
,AVG(ma80s  )OVER() ma80s_av
,AVG(ma200s )OVER() ma200s_av
,AVG(d0102  )OVER() d0102_av
,AVG(d0103  )OVER() d0103_av
,AVG(d0104  )OVER() d0104_av
,AVG(d0105  )OVER() d0105_av
,AVG(d0109  )OVER() d0109_av
,AVG(d0120  )OVER() d0120_av
,AVG(d0140  )OVER() d0140_av
,AVG(d0180  )OVER() d0180_av
,AVG(d01200 )OVER() d01200_av
,AVG(d0203  )OVER() d0203_av
,AVG(d0204  )OVER() d0204_av
,AVG(d0205  )OVER() d0205_av
,AVG(d0209  )OVER() d0209_av
,AVG(d0220  )OVER() d0220_av
,AVG(d0240  )OVER() d0240_av
,AVG(d0280  )OVER() d0280_av
,AVG(d02200 )OVER() d02200_av
,AVG(d0304  )OVER() d0304_av
,AVG(d0305  )OVER() d0305_av
,AVG(d0309  )OVER() d0309_av
,AVG(d0320  )OVER() d0320_av
,AVG(d0340  )OVER() d0340_av
,AVG(d0380  )OVER() d0380_av
,AVG(d03200 )OVER() d03200_av
,AVG(d0405  )OVER() d0405_av
,AVG(d0409  )OVER() d0409_av
,AVG(d0420  )OVER() d0420_av
,AVG(d0440  )OVER() d0440_av
,AVG(d0480  )OVER() d0480_av
,AVG(d04200 )OVER() d04200_av
,AVG(d0509  )OVER() d0509_av
,AVG(d0520  )OVER() d0520_av
,AVG(d0540  )OVER() d0540_av
,AVG(d0580  )OVER() d0580_av
,AVG(d05200 )OVER() d05200_av
,AVG(d0920  )OVER() d0920_av
,AVG(d0940  )OVER() d0940_av
,AVG(d0980  )OVER() d0980_av
,AVG(d09200 )OVER() d09200_av
,AVG(d2040  )OVER() d2040_av
,AVG(d2080  )OVER() d2080_av
,AVG(d20200 )OVER() d20200_av
,AVG(d4080  )OVER() d4080_av
,AVG(d40200 )OVER() d40200_av
,AVG(d80200 )OVER() d80200_av
,AVG(ma02sd )OVER() ma02sd_av
,AVG(ma03sd )OVER() ma03sd_av
,AVG(ma04sd )OVER() ma04sd_av
,AVG(ma05sd )OVER() ma05sd_av
,AVG(ma09sd )OVER() ma09sd_av
,AVG(ma20sd )OVER() ma20sd_av
,AVG(ma40sd )OVER() ma40sd_av
,AVG(ma80sd )OVER() ma80sd_av
,AVG(ma200sd )OVER() ma200sd_av
FROM tv14
ORDER BY ydate
;

DROP   TABLE IF EXISTS tv16st;
CREATE TABLE tv16st AS
SELECT
tkr,ydate
,ng1
,ng2
,ng3
,ng4
,ng5
,y1
,y2
,y3
,y4
,y5
,CASE WHEN ma02s   <ma02s_av   -ma02s_st    THEN 1 ELSE 0 END ma02s_lt
,CASE WHEN ma03s   <ma03s_av   -ma03s_st    THEN 1 ELSE 0 END ma03s_lt
,CASE WHEN ma04s   <ma04s_av   -ma04s_st    THEN 1 ELSE 0 END ma04s_lt
,CASE WHEN ma05s   <ma05s_av   -ma05s_st    THEN 1 ELSE 0 END ma05s_lt
,CASE WHEN ma09s   <ma09s_av   -ma09s_st    THEN 1 ELSE 0 END ma09s_lt
,CASE WHEN ma20s   <ma20s_av   -ma20s_st    THEN 1 ELSE 0 END ma20s_lt
,CASE WHEN ma40s   <ma40s_av   -ma40s_st    THEN 1 ELSE 0 END ma40s_lt
,CASE WHEN ma80s   <ma80s_av   -ma80s_st    THEN 1 ELSE 0 END ma80s_lt
,CASE WHEN ma200s  <ma200s_av  -ma200s_st   THEN 1 ELSE 0 END ma200s_lt
,CASE WHEN d0102   <d0102_av   -d0102_st    THEN 1 ELSE 0 END d0102_lt
,CASE WHEN d0103   <d0103_av   -d0103_st    THEN 1 ELSE 0 END d0103_lt
,CASE WHEN d0104   <d0104_av   -d0104_st    THEN 1 ELSE 0 END d0104_lt
,CASE WHEN d0105   <d0105_av   -d0105_st    THEN 1 ELSE 0 END d0105_lt
,CASE WHEN d0109   <d0109_av   -d0109_st    THEN 1 ELSE 0 END d0109_lt
,CASE WHEN d0120   <d0120_av   -d0120_st    THEN 1 ELSE 0 END d0120_lt
,CASE WHEN d0140   <d0140_av   -d0140_st    THEN 1 ELSE 0 END d0140_lt
,CASE WHEN d0180   <d0180_av   -d0180_st    THEN 1 ELSE 0 END d0180_lt
,CASE WHEN d01200  <d01200_av  -d01200_st   THEN 1 ELSE 0 END d01200_lt
,CASE WHEN d0203   <d0203_av   -d0203_st    THEN 1 ELSE 0 END d0203_lt
,CASE WHEN d0204   <d0204_av   -d0204_st    THEN 1 ELSE 0 END d0204_lt
,CASE WHEN d0205   <d0205_av   -d0205_st    THEN 1 ELSE 0 END d0205_lt
,CASE WHEN d0209   <d0209_av   -d0209_st    THEN 1 ELSE 0 END d0209_lt
,CASE WHEN d0220   <d0220_av   -d0220_st    THEN 1 ELSE 0 END d0220_lt
,CASE WHEN d0240   <d0240_av   -d0240_st    THEN 1 ELSE 0 END d0240_lt
,CASE WHEN d0280   <d0280_av   -d0280_st    THEN 1 ELSE 0 END d0280_lt
,CASE WHEN d02200  <d02200_av  -d02200_st   THEN 1 ELSE 0 END d02200_lt
,CASE WHEN d0304   <d0304_av   -d0304_st    THEN 1 ELSE 0 END d0304_lt
,CASE WHEN d0305   <d0305_av   -d0305_st    THEN 1 ELSE 0 END d0305_lt
,CASE WHEN d0309   <d0309_av   -d0309_st    THEN 1 ELSE 0 END d0309_lt
,CASE WHEN d0320   <d0320_av   -d0320_st    THEN 1 ELSE 0 END d0320_lt
,CASE WHEN d0340   <d0340_av   -d0340_st    THEN 1 ELSE 0 END d0340_lt
,CASE WHEN d0380   <d0380_av   -d0380_st    THEN 1 ELSE 0 END d0380_lt
,CASE WHEN d03200  <d03200_av  -d03200_st   THEN 1 ELSE 0 END d03200_lt
,CASE WHEN d0405   <d0405_av   -d0405_st    THEN 1 ELSE 0 END d0405_lt
,CASE WHEN d0409   <d0409_av   -d0409_st    THEN 1 ELSE 0 END d0409_lt
,CASE WHEN d0420   <d0420_av   -d0420_st    THEN 1 ELSE 0 END d0420_lt
,CASE WHEN d0440   <d0440_av   -d0440_st    THEN 1 ELSE 0 END d0440_lt
,CASE WHEN d0480   <d0480_av   -d0480_st    THEN 1 ELSE 0 END d0480_lt
,CASE WHEN d04200  <d04200_av  -d04200_st   THEN 1 ELSE 0 END d04200_lt
,CASE WHEN d0509   <d0509_av   -d0509_st    THEN 1 ELSE 0 END d0509_lt
,CASE WHEN d0520   <d0520_av   -d0520_st    THEN 1 ELSE 0 END d0520_lt
,CASE WHEN d0540   <d0540_av   -d0540_st    THEN 1 ELSE 0 END d0540_lt
,CASE WHEN d0580   <d0580_av   -d0580_st    THEN 1 ELSE 0 END d0580_lt
,CASE WHEN d05200  <d05200_av  -d05200_st   THEN 1 ELSE 0 END d05200_lt
,CASE WHEN d0920   <d0920_av   -d0920_st    THEN 1 ELSE 0 END d0920_lt
,CASE WHEN d0940   <d0940_av   -d0940_st    THEN 1 ELSE 0 END d0940_lt
,CASE WHEN d0980   <d0980_av   -d0980_st    THEN 1 ELSE 0 END d0980_lt
,CASE WHEN d09200  <d09200_av  -d09200_st   THEN 1 ELSE 0 END d09200_lt
,CASE WHEN d2040   <d2040_av   -d2040_st    THEN 1 ELSE 0 END d2040_lt
,CASE WHEN d2080   <d2080_av   -d2080_st    THEN 1 ELSE 0 END d2080_lt
,CASE WHEN d20200  <d20200_av  -d20200_st   THEN 1 ELSE 0 END d20200_lt
,CASE WHEN d4080   <d4080_av   -d4080_st    THEN 1 ELSE 0 END d4080_lt
,CASE WHEN d40200  <d40200_av  -d40200_st   THEN 1 ELSE 0 END d40200_lt
,CASE WHEN d80200  <d80200_av  -d80200_st   THEN 1 ELSE 0 END d80200_lt
,CASE WHEN ma02sd  <ma02sd_av  -ma02sd_st   THEN 1 ELSE 0 END ma02sd_lt
,CASE WHEN ma03sd  <ma03sd_av  -ma03sd_st   THEN 1 ELSE 0 END ma03sd_lt
,CASE WHEN ma04sd  <ma04sd_av  -ma04sd_st   THEN 1 ELSE 0 END ma04sd_lt
,CASE WHEN ma05sd  <ma05sd_av  -ma05sd_st   THEN 1 ELSE 0 END ma05sd_lt
,CASE WHEN ma09sd  <ma09sd_av  -ma09sd_st   THEN 1 ELSE 0 END ma09sd_lt
,CASE WHEN ma20sd  <ma20sd_av  -ma20sd_st   THEN 1 ELSE 0 END ma20sd_lt
,CASE WHEN ma40sd  <ma40sd_av  -ma40sd_st   THEN 1 ELSE 0 END ma40sd_lt
,CASE WHEN ma80sd  <ma80sd_av  -ma80sd_st   THEN 1 ELSE 0 END ma80sd_lt
,CASE WHEN ma200sd <ma200sd_av -ma200sd_st  THEN 1 ELSE 0 END ma200sd_lt
,CASE WHEN ma02s   >ma02s_av   +ma02s_st    THEN 1 ELSE 0 END ma02s_gt
,CASE WHEN ma03s   >ma03s_av   +ma03s_st    THEN 1 ELSE 0 END ma03s_gt
,CASE WHEN ma04s   >ma04s_av   +ma04s_st    THEN 1 ELSE 0 END ma04s_gt
,CASE WHEN ma05s   >ma05s_av   +ma05s_st    THEN 1 ELSE 0 END ma05s_gt
,CASE WHEN ma09s   >ma09s_av   +ma09s_st    THEN 1 ELSE 0 END ma09s_gt
,CASE WHEN ma20s   >ma20s_av   +ma20s_st    THEN 1 ELSE 0 END ma20s_gt
,CASE WHEN ma40s   >ma40s_av   +ma40s_st    THEN 1 ELSE 0 END ma40s_gt
,CASE WHEN ma80s   >ma80s_av   +ma80s_st    THEN 1 ELSE 0 END ma80s_gt
,CASE WHEN ma200s  >ma200s_av  +ma200s_st   THEN 1 ELSE 0 END ma200s_gt
,CASE WHEN d0102   >d0102_av   +d0102_st    THEN 1 ELSE 0 END d0102_gt
,CASE WHEN d0103   >d0103_av   +d0103_st    THEN 1 ELSE 0 END d0103_gt
,CASE WHEN d0104   >d0104_av   +d0104_st    THEN 1 ELSE 0 END d0104_gt
,CASE WHEN d0105   >d0105_av   +d0105_st    THEN 1 ELSE 0 END d0105_gt
,CASE WHEN d0109   >d0109_av   +d0109_st    THEN 1 ELSE 0 END d0109_gt
,CASE WHEN d0120   >d0120_av   +d0120_st    THEN 1 ELSE 0 END d0120_gt
,CASE WHEN d0140   >d0140_av   +d0140_st    THEN 1 ELSE 0 END d0140_gt
,CASE WHEN d0180   >d0180_av   +d0180_st    THEN 1 ELSE 0 END d0180_gt
,CASE WHEN d01200  >d01200_av  +d01200_st   THEN 1 ELSE 0 END d01200_gt
,CASE WHEN d0203   >d0203_av   +d0203_st    THEN 1 ELSE 0 END d0203_gt
,CASE WHEN d0204   >d0204_av   +d0204_st    THEN 1 ELSE 0 END d0204_gt
,CASE WHEN d0205   >d0205_av   +d0205_st    THEN 1 ELSE 0 END d0205_gt
,CASE WHEN d0209   >d0209_av   +d0209_st    THEN 1 ELSE 0 END d0209_gt
,CASE WHEN d0220   >d0220_av   +d0220_st    THEN 1 ELSE 0 END d0220_gt
,CASE WHEN d0240   >d0240_av   +d0240_st    THEN 1 ELSE 0 END d0240_gt
,CASE WHEN d0280   >d0280_av   +d0280_st    THEN 1 ELSE 0 END d0280_gt
,CASE WHEN d02200  >d02200_av  +d02200_st   THEN 1 ELSE 0 END d02200_gt
,CASE WHEN d0304   >d0304_av   +d0304_st    THEN 1 ELSE 0 END d0304_gt
,CASE WHEN d0305   >d0305_av   +d0305_st    THEN 1 ELSE 0 END d0305_gt
,CASE WHEN d0309   >d0309_av   +d0309_st    THEN 1 ELSE 0 END d0309_gt
,CASE WHEN d0320   >d0320_av   +d0320_st    THEN 1 ELSE 0 END d0320_gt
,CASE WHEN d0340   >d0340_av   +d0340_st    THEN 1 ELSE 0 END d0340_gt
,CASE WHEN d0380   >d0380_av   +d0380_st    THEN 1 ELSE 0 END d0380_gt
,CASE WHEN d03200  >d03200_av  +d03200_st   THEN 1 ELSE 0 END d03200_gt
,CASE WHEN d0405   >d0405_av   +d0405_st    THEN 1 ELSE 0 END d0405_gt
,CASE WHEN d0409   >d0409_av   +d0409_st    THEN 1 ELSE 0 END d0409_gt
,CASE WHEN d0420   >d0420_av   +d0420_st    THEN 1 ELSE 0 END d0420_gt
,CASE WHEN d0440   >d0440_av   +d0440_st    THEN 1 ELSE 0 END d0440_gt
,CASE WHEN d0480   >d0480_av   +d0480_st    THEN 1 ELSE 0 END d0480_gt
,CASE WHEN d04200  >d04200_av  +d04200_st   THEN 1 ELSE 0 END d04200_gt
,CASE WHEN d0509   >d0509_av   +d0509_st    THEN 1 ELSE 0 END d0509_gt
,CASE WHEN d0520   >d0520_av   +d0520_st    THEN 1 ELSE 0 END d0520_gt
,CASE WHEN d0540   >d0540_av   +d0540_st    THEN 1 ELSE 0 END d0540_gt
,CASE WHEN d0580   >d0580_av   +d0580_st    THEN 1 ELSE 0 END d0580_gt
,CASE WHEN d05200  >d05200_av  +d05200_st   THEN 1 ELSE 0 END d05200_gt
,CASE WHEN d0920   >d0920_av   +d0920_st    THEN 1 ELSE 0 END d0920_gt
,CASE WHEN d0940   >d0940_av   +d0940_st    THEN 1 ELSE 0 END d0940_gt
,CASE WHEN d0980   >d0980_av   +d0980_st    THEN 1 ELSE 0 END d0980_gt
,CASE WHEN d09200  >d09200_av  +d09200_st   THEN 1 ELSE 0 END d09200_gt
,CASE WHEN d2040   >d2040_av   +d2040_st    THEN 1 ELSE 0 END d2040_gt
,CASE WHEN d2080   >d2080_av   +d2080_st    THEN 1 ELSE 0 END d2080_gt
,CASE WHEN d20200  >d20200_av  +d20200_st   THEN 1 ELSE 0 END d20200_gt
,CASE WHEN d4080   >d4080_av   +d4080_st    THEN 1 ELSE 0 END d4080_gt
,CASE WHEN d40200  >d40200_av  +d40200_st   THEN 1 ELSE 0 END d40200_gt
,CASE WHEN d80200  >d80200_av  +d80200_st   THEN 1 ELSE 0 END d80200_gt
,CASE WHEN ma02sd  >ma02sd_av  +ma02sd_st   THEN 1 ELSE 0 END ma02sd_gt
,CASE WHEN ma03sd  >ma03sd_av  +ma03sd_st   THEN 1 ELSE 0 END ma03sd_gt
,CASE WHEN ma04sd  >ma04sd_av  +ma04sd_st   THEN 1 ELSE 0 END ma04sd_gt
,CASE WHEN ma05sd  >ma05sd_av  +ma05sd_st   THEN 1 ELSE 0 END ma05sd_gt
,CASE WHEN ma09sd  >ma09sd_av  +ma09sd_st   THEN 1 ELSE 0 END ma09sd_gt
,CASE WHEN ma20sd  >ma20sd_av  +ma20sd_st   THEN 1 ELSE 0 END ma20sd_gt
,CASE WHEN ma40sd  >ma40sd_av  +ma40sd_st   THEN 1 ELSE 0 END ma40sd_gt
,CASE WHEN ma80sd  >ma80sd_av  +ma80sd_st   THEN 1 ELSE 0 END ma80sd_gt
,CASE WHEN ma200sd >ma200sd_av +ma200sd_st  THEN 1 ELSE 0 END ma200sd_gt
FROM tv14st
ORDER BY ydate
;

DROP   TABLE IF EXISTS tv18st;
CREATE TABLE tv18st AS
SELECT
tkr,ydate
,ng1
,ng2
,ng3
,ng4
,ng5
,y1
,y2
,y3
,y4
,y5
,ma02s_lt
,ma03s_lt
,ma04s_lt
,ma05s_lt
,ma09s_lt
,ma20s_lt
,ma40s_lt
,ma80s_lt
,ma200s_lt
,d0102_lt
,d0103_lt
,d0104_lt
,d0105_lt
,d0109_lt
,d0120_lt
,d0140_lt
,d0180_lt
,d01200_lt
,d0203_lt
,d0204_lt
,d0205_lt
,d0209_lt
,d0220_lt
,d0240_lt
,d0280_lt
,d02200_lt
,d0304_lt
,d0305_lt
,d0309_lt
,d0320_lt
,d0340_lt
,d0380_lt
,d03200_lt
,d0405_lt
,d0409_lt
,d0420_lt
,d0440_lt
,d0480_lt
,d04200_lt
,d0509_lt
,d0520_lt
,d0540_lt
,d0580_lt
,d05200_lt
,d0920_lt
,d0940_lt
,d0980_lt
,d09200_lt
,d2040_lt
,d2080_lt
,d20200_lt
,d4080_lt
,d40200_lt
,d80200_lt
,ma02sd_lt
,ma03sd_lt
,ma04sd_lt
,ma05sd_lt
,ma09sd_lt
,ma20sd_lt
,ma40sd_lt
,ma80sd_lt
,ma200sd_lt
,ma02s_gt
,ma03s_gt
,ma04s_gt
,ma05s_gt
,ma09s_gt
,ma20s_gt
,ma40s_gt
,ma80s_gt
,ma200s_gt
,d0102_gt
,d0103_gt
,d0104_gt
,d0105_gt
,d0109_gt
,d0120_gt
,d0140_gt
,d0180_gt
,d01200_gt
,d0203_gt
,d0204_gt
,d0205_gt
,d0209_gt
,d0220_gt
,d0240_gt
,d0280_gt
,d02200_gt
,d0304_gt
,d0305_gt
,d0309_gt
,d0320_gt
,d0340_gt
,d0380_gt
,d03200_gt
,d0405_gt
,d0409_gt
,d0420_gt
,d0440_gt
,d0480_gt
,d04200_gt
,d0509_gt
,d0520_gt
,d0540_gt
,d0580_gt
,d05200_gt
,d0920_gt
,d0940_gt
,d0980_gt
,d09200_gt
,d2040_gt
,d2080_gt
,d20200_gt
,d4080_gt
,d40200_gt
,d80200_gt
,ma02sd_gt
,ma03sd_gt
,ma04sd_gt
,ma05sd_gt
,ma09sd_gt
,ma20sd_gt
,ma40sd_gt
,ma80sd_gt
,ma200sd_gt
,ma02s_lt
+ma03s_lt
+ma04s_lt
+ma05s_lt
+ma09s_lt
+ma20s_lt
+ma40s_lt
+ma80s_lt
+ma200s_lt
+d0102_lt
+d0103_lt
+d0104_lt
+d0105_lt
+d0109_lt
+d0120_lt
+d0140_lt
+d0180_lt
+d01200_lt
+d0203_lt
+d0204_lt
+d0205_lt
+d0209_lt
+d0220_lt
+d0240_lt
+d0280_lt
+d02200_lt
+d0304_lt
+d0305_lt
+d0309_lt
+d0320_lt
+d0340_lt
+d0380_lt
+d03200_lt
+d0405_lt
+d0409_lt
+d0420_lt
+d0440_lt
+d0480_lt
+d04200_lt
+d0509_lt
+d0520_lt
+d0540_lt
+d0580_lt
+d05200_lt
+d0920_lt
+d0940_lt
+d0980_lt
+d09200_lt
+d2040_lt
+d2080_lt
+d20200_lt
+d4080_lt
+d40200_lt
+d80200_lt
+ma02sd_lt
+ma03sd_lt
+ma04sd_lt
+ma05sd_lt
+ma09sd_lt
+ma20sd_lt
+ma40sd_lt
+ma80sd_lt
+ma200sd_lt ltsum
,ma02s_gt
+ma03s_gt
+ma04s_gt
+ma05s_gt
+ma09s_gt
+ma20s_gt
+ma40s_gt
+ma80s_gt
+ma200s_gt
+d0102_gt
+d0103_gt
+d0104_gt
+d0105_gt
+d0109_gt
+d0120_gt
+d0140_gt
+d0180_gt
+d01200_gt
+d0203_gt
+d0204_gt
+d0205_gt
+d0209_gt
+d0220_gt
+d0240_gt
+d0280_gt
+d02200_gt
+d0304_gt
+d0305_gt
+d0309_gt
+d0320_gt
+d0340_gt
+d0380_gt
+d03200_gt
+d0405_gt
+d0409_gt
+d0420_gt
+d0440_gt
+d0480_gt
+d04200_gt
+d0509_gt
+d0520_gt
+d0540_gt
+d0580_gt
+d05200_gt
+d0920_gt
+d0940_gt
+d0980_gt
+d09200_gt
+d2040_gt
+d2080_gt
+d20200_gt
+d4080_gt
+d40200_gt
+d80200_gt
+ma02sd_gt
+ma03sd_gt
+ma04sd_gt
+ma05sd_gt
+ma09sd_gt
+ma20sd_gt
+ma40sd_gt
+ma80sd_gt
+ma200sd_gt gtsum
FROM tv16st
ORDER BY ydate
;

DROP   TABLE IF EXISTS tv20st;
CREATE TABLE tv20st AS
SELECT
tkr,ydate
,ng1
,ng2
,ng3
,ng4
,ng5
,y1
,y2
,y3
,y4
,y5
,ma02s_lt
,ma03s_lt
,ma04s_lt
,ma05s_lt
,ma09s_lt
,ma20s_lt
,ma40s_lt
,ma80s_lt
,ma200s_lt
,d0102_lt
,d0103_lt
,d0104_lt
,d0105_lt
,d0109_lt
,d0120_lt
,d0140_lt
,d0180_lt
,d01200_lt
,d0203_lt
,d0204_lt
,d0205_lt
,d0209_lt
,d0220_lt
,d0240_lt
,d0280_lt
,d02200_lt
,d0304_lt
,d0305_lt
,d0309_lt
,d0320_lt
,d0340_lt
,d0380_lt
,d03200_lt
,d0405_lt
,d0409_lt
,d0420_lt
,d0440_lt
,d0480_lt
,d04200_lt
,d0509_lt
,d0520_lt
,d0540_lt
,d0580_lt
,d05200_lt
,d0920_lt
,d0940_lt
,d0980_lt
,d09200_lt
,d2040_lt
,d2080_lt
,d20200_lt
,d4080_lt
,d40200_lt
,d80200_lt
,ma02sd_lt
,ma03sd_lt
,ma04sd_lt
,ma05sd_lt
,ma09sd_lt
,ma20sd_lt
,ma40sd_lt
,ma80sd_lt
,ma200sd_lt
,ma02s_gt
,ma03s_gt
,ma04s_gt
,ma05s_gt
,ma09s_gt
,ma20s_gt
,ma40s_gt
,ma80s_gt
,ma200s_gt
,d0102_gt
,d0103_gt
,d0104_gt
,d0105_gt
,d0109_gt
,d0120_gt
,d0140_gt
,d0180_gt
,d01200_gt
,d0203_gt
,d0204_gt
,d0205_gt
,d0209_gt
,d0220_gt
,d0240_gt
,d0280_gt
,d02200_gt
,d0304_gt
,d0305_gt
,d0309_gt
,d0320_gt
,d0340_gt
,d0380_gt
,d03200_gt
,d0405_gt
,d0409_gt
,d0420_gt
,d0440_gt
,d0480_gt
,d04200_gt
,d0509_gt
,d0520_gt
,d0540_gt
,d0580_gt
,d05200_gt
,d0920_gt
,d0940_gt
,d0980_gt
,d09200_gt
,d2040_gt
,d2080_gt
,d20200_gt
,d4080_gt
,d40200_gt
,d80200_gt
,ma02sd_gt
,ma03sd_gt
,ma04sd_gt
,ma05sd_gt
,ma09sd_gt
,ma20sd_gt
,ma40sd_gt
,ma80sd_gt
,ma200sd_gt
,ltsum
,gtsum
FROM tv18st
ORDER BY ydate
;

DROP   TABLE IF EXISTS tv22st;
CREATE TABLE tv22st AS
SELECT * FROM tv20st
WHERE ltsum>0
OR    gtsum>0
;

DROP   TABLE IF EXISTS tvsource;
CREATE TABLE tvsource AS
SELECT
tkr,ydate
,y1
,y2
,y3
,y4
,y5
,ng1
,ng2
,ng3
,ng4
,ng5
,ma02s_lt
,ma03s_lt
,ma04s_lt
,ma05s_lt
,ma09s_lt
,ma20s_lt
,ma40s_lt
,ma80s_lt
,ma200s_lt
,d0102_lt
,d0103_lt
,d0104_lt
,d0105_lt
,d0109_lt
,d0120_lt
,d0140_lt
,d0180_lt
,d01200_lt
,d0203_lt
,d0204_lt
,d0205_lt
,d0209_lt
,d0220_lt
,d0240_lt
,d0280_lt
,d02200_lt
,d0304_lt
,d0305_lt
,d0309_lt
,d0320_lt
,d0340_lt
,d0380_lt
,d03200_lt
,d0405_lt
,d0409_lt
,d0420_lt
,d0440_lt
,d0480_lt
,d04200_lt
,d0509_lt
,d0520_lt
,d0540_lt
,d0580_lt
,d05200_lt
,d0920_lt
,d0940_lt
,d0980_lt
,d09200_lt
,d2040_lt
,d2080_lt
,d20200_lt
,d4080_lt
,d40200_lt
,d80200_lt
,ma02sd_lt
,ma03sd_lt
,ma04sd_lt
,ma05sd_lt
,ma09sd_lt
,ma20sd_lt
,ma40sd_lt
,ma80sd_lt
,ma200sd_lt
,ma02s_gt
,ma03s_gt
,ma04s_gt
,ma05s_gt
,ma09s_gt
,ma20s_gt
,ma40s_gt
,ma80s_gt
,ma200s_gt
,d0102_gt
,d0103_gt
,d0104_gt
,d0105_gt
,d0109_gt
,d0120_gt
,d0140_gt
,d0180_gt
,d01200_gt
,d0203_gt
,d0204_gt
,d0205_gt
,d0209_gt
,d0220_gt
,d0240_gt
,d0280_gt
,d02200_gt
,d0304_gt
,d0305_gt
,d0309_gt
,d0320_gt
,d0340_gt
,d0380_gt
,d03200_gt
,d0405_gt
,d0409_gt
,d0420_gt
,d0440_gt
,d0480_gt
,d04200_gt
,d0509_gt
,d0520_gt
,d0540_gt
,d0580_gt
,d05200_gt
,d0920_gt
,d0940_gt
,d0980_gt
,d09200_gt
,d2040_gt
,d2080_gt
,d20200_gt
,d4080_gt
,d40200_gt
,d80200_gt
,ma02sd_gt
,ma03sd_gt
,ma04sd_gt
,ma05sd_gt
,ma09sd_gt
,ma20sd_gt
,ma40sd_gt
,ma80sd_gt
,ma200sd_gt
FROM tv22st
WHERE -180 + ydate > (SELECT MIN(ydate) FROM tv22st)
-- AND ydate < '2013-01-01'
AND    ydate < :BDATE
ORDER BY ydate
;

