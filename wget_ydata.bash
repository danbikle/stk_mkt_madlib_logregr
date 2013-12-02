#!/bin/bash

# ~/tv/wget_ydata.bash

# I use this script to wget some yahoo stock prices.

mkdir -p /tmp/ydata/
cd       /tmp/ydata/

wget --output-document=SPY.csv  http://ichart.finance.yahoo.com/table.csv?s=SPY 
wget --output-document=BA.csv   http://ichart.finance.yahoo.com/table.csv?s=BA 
wget --output-document=CAT.csv	http://ichart.finance.yahoo.com/table.csv?s=CAT
wget --output-document=CVX.csv	http://ichart.finance.yahoo.com/table.csv?s=CVX
wget --output-document=DD.csv	http://ichart.finance.yahoo.com/table.csv?s=DD 
wget --output-document=DIS.csv	http://ichart.finance.yahoo.com/table.csv?s=DIS
wget --output-document=ED.csv	http://ichart.finance.yahoo.com/table.csv?s=ED 
wget --output-document=GE.csv	http://ichart.finance.yahoo.com/table.csv?s=GE 
wget --output-document=HON.csv	http://ichart.finance.yahoo.com/table.csv?s=HON
wget --output-document=HPQ.csv	http://ichart.finance.yahoo.com/table.csv?s=HPQ
wget --output-document=IBM.csv	http://ichart.finance.yahoo.com/table.csv?s=IBM
wget --output-document=JNJ.csv	http://ichart.finance.yahoo.com/table.csv?s=JNJ
wget --output-document=KO.csv	http://ichart.finance.yahoo.com/table.csv?s=KO 
wget --output-document=MCD.csv	http://ichart.finance.yahoo.com/table.csv?s=MCD
wget --output-document=MMM.csv	http://ichart.finance.yahoo.com/table.csv?s=MMM
wget --output-document=MO.csv	http://ichart.finance.yahoo.com/table.csv?s=MO 
wget --output-document=MRK.csv	http://ichart.finance.yahoo.com/table.csv?s=MRK
wget --output-document=MRO.csv	http://ichart.finance.yahoo.com/table.csv?s=MRO
wget --output-document=NAV.csv	http://ichart.finance.yahoo.com/table.csv?s=NAV
wget --output-document=PG.csv	http://ichart.finance.yahoo.com/table.csv?s=PG 
wget --output-document=XOM.csv	http://ichart.finance.yahoo.com/table.csv?s=XOM

exit
