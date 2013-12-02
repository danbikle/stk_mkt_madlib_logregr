#!/bin/bash

# ~/tv/postgres/load_ydata.bash

# I use this script to load data from CSV files into table, ydata.

# This script is only a demo.
# If I want to load hundreds of tickers, instead of just these,
# I use SQL (or some other looping mechanism)
# to build a script and then I run that.

# I already ran the wget script below so I comment it out.
# You might find it useful to run it here:
# ~/tv/wget_ydata.bash
# If you did run the above wget script,
# you should have CSV files in /tmp/ydata/

# cd to the place where I have this repo.
# On my host that place is ~/tv/

if [ -e ~/tv/ ] ; then
  echo You are good to go.
else
  echo I have a problem.
  echo I should see a directory named ~/tv/
  echo Please study $0 for more clues.
  echo bye.
  exit 0
fi

cd ~/tv/
cd postgres/

# I add tkr values to the CSV data and create one large CSV file.

rm -f /tmp/ydata/ydata.csv

grep -v Date /tmp/ydata/SPY.csv | sed '1,$s/^/SPY,/'  >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/BA.csv  | sed '1,$s/^/BA,/'   >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/CAT.csv	| sed '1,$s/^/CAT,/'  >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/CVX.csv	| sed '1,$s/^/CVX,/'  >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/DD.csv	| sed '1,$s/^/DD,/'   >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/DIS.csv	| sed '1,$s/^/DIS,/'  >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/ED.csv	| sed '1,$s/^/ED,/'   >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/GE.csv	| sed '1,$s/^/GE,/'   >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/HON.csv	| sed '1,$s/^/HON,/'  >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/HPQ.csv	| sed '1,$s/^/HPQ,/'  >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/IBM.csv	| sed '1,$s/^/IBM,/'  >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/JNJ.csv	| sed '1,$s/^/JNJ,/'  >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/KO.csv	| sed '1,$s/^/KO,/'   >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/MCD.csv	| sed '1,$s/^/MCD,/'  >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/MMM.csv	| sed '1,$s/^/MMM,/'  >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/MO.csv	| sed '1,$s/^/MO,/'   >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/MRK.csv	| sed '1,$s/^/MRK,/'  >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/MRO.csv	| sed '1,$s/^/MRO,/'  >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/NAV.csv	| sed '1,$s/^/NAV,/'  >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/PG.csv	| sed '1,$s/^/PG,/'   >> /tmp/ydata/ydata.csv
grep -v Date /tmp/ydata/XOM.csv	| sed '1,$s/^/XOM,/'  >> /tmp/ydata/ydata.csv

echo 'Here is head and tail of the CSV file I want to load:'
head -3 /tmp/ydata/ydata.csv
tail -3 /tmp/ydata/ydata.csv

# Time for me to call psql which calls the COPY command to copy
# rows out of /tmp/ydata/ydata.csv
# into the table, ydata.

# Ensure that postgres server can read the data:
chmod 755 /tmp/ydata/
chmod 644 /tmp/ydata/ydata.csv

# I assume postgres authentication is setup.
# I follow clues I wrote here: 
# ~/tv/postgres/readme_authentication.txt

echo 'I might see an error here:'
echo 'ERROR:  relation "ydata" already exists'
echo 'It is okay. I need to ensure that ydata exists'
echo 'before I try to fill it.'
./psqlmad.bash<<EOF
-- Ensure that ydata exists.
-- I might get an error here:
\i cr_ydata.sql 

-- Assume current data in ydata is not needed.
-- Since this is only a demo, I can toss it in the trash:

TRUNCATE TABLE ydata;

-- Now fill ydata

COPY ydata (
tkr
,ydate     
,opn      
,mx
,mn
,closing_price
,vol
,adjclse
) FROM '/tmp/ydata/ydata.csv' WITH csv
;

EOF

# At this point,
# my table, ydata, should be full of rows from /tmp/ydata/ydata.csv'

echo 'Here is the load report:'

./psqlmad.bash<<EOF
SELECT MIN(ydate),COUNT(tkr),MAX(ydate) FROM ydata;

SELECT tkr, MIN(ydate),COUNT(tkr),MAX(ydate) FROM ydata GROUP BY tkr ORDER BY tkr ;
EOF


# Since I am about to UPDATE the closing_price column,
# I will backup the data in it.
echo 'The command below might issue an error:'
echo 'ERROR:  table "ydata_copy" does not exist'
echo 'I need to drop it before I create and refill it.'
./psqlmad.bash<<EOF
DROP   TABLE ydata_copy;
-- Above command might give error

CREATE TABLE ydata_copy AS
SELECT
tkr
,ydate   
,opn     
,mx      
,mn      
,closing_price
,vol     
,adjclse 
,closing_price AS closing_price_orig
FROM ydata
ORDER BY tkr,ydate
;

DROP   TABLE ydata;
CREATE TABLE ydata AS SELECT * FROM ydata_copy;

-- Run the load report again

SELECT MIN(ydate),COUNT(tkr),MAX(ydate) FROM ydata;

SELECT tkr, MIN(ydate),COUNT(tkr),MAX(ydate) FROM ydata GROUP BY tkr ORDER BY tkr ;
EOF

# So, now I have the data loaded.  Usually my next step is to cd ../
# and call 
#  ../cr_upd_cp.bash 
# to create 
#  ../update_closing_price.sql.
# Then, I call update_closing_price.sql to UPDATE closing_price in ydata.

# Another thing I might do is look for abrupt, abnormal 
# changes in closing_price using ../qry_abrupt.sql
# After I UPDATE, those abrupt changes (due to stock splits) 
# should be gone.

# The scripts in ../ should work for both Oracle and Postgres.

exit

