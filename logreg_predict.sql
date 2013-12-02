--
-- ~/tv/logreg_predict.sql
--
-- ref:
-- http://doc.madlib.net/latest/group__grp__logreg.html

-- The logistic regression training function has the following format:
-- 
-- logregr_train( source_table,
--                out_table,
--                dependent_varname,
--                independent_varname,
--                grouping_cols,
--                max_iter,
--                optimizer,
--                tolerance,
--                verbose
--              )

-- In this script:
-- source_table is tvsource
-- out_table    is tvout
-- dependent_varname is y3
-- independent_varname is ARRAY[1, ma02s_lt, ma03s_lt, ... ,ma200sd_gt]
-- grouping_cols is ... NULL 
-- max_iter  is 999
-- optimizer defaults to irls (Iteratively reweighted least squares )
-- tolerance defaults to 0.0001

-- Start with setting up the out of sample data
-- which I define to be data created AFTER boundry date:

DROP   TABLE IF EXISTS tvoos CASCADE;
CREATE TABLE tvoos AS
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
-- WHERE ydate > '2013-01-01'
WHERE    ydate > :BDATE
AND      tkr = :TKR
ORDER BY ydate
;


DROP TABLE IF EXISTS tvout CASCADE;

SELECT logregr_train( 'tvsource',
'tvout',
'y3',
'ARRAY[1
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
]',
NULL,
999             
);

--
-- rpt, Look at the regression created by MADlib:
--
\x on
SELECT * FROM tvout;
\x off

-- Now predict my oos data
CREATE OR REPLACE VIEW logreg_predictions AS
SELECT
tkr,ydate
,y3
,ng3
,madlib.logistic(madlib.array_dot(tvout.coef, array[1
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
]::float8[] ) ) AS prob
FROM tvoos, tvout
ORDER BY ydate
;

-- Save the predictions for possible later reporting.
-- I use a parent script to drop predictions12
-- when I want to fill it with fresh predictions.
-- Initially I want predictions12 empty:
CREATE TABLE predictions12 AS SELECT * FROM logreg_predictions WHERE 1 = 0;

INSERT INTO predictions12 SELECT * FROM logreg_predictions;
