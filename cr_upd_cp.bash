#!/bin/bash

# ~/tv/cr_upd_cp.bash

# I use this script to create an UPDATE closing_price script 
# from tkr_split_dates.csv

echo "This file created by $0" > update_closing_price_awk.txt
grep "[0-2]" tkr_split_dates.csv|awk '{print "UPDATE ydata SET closing_price=closing_price*"$3" WHERE tkr=:"$1": AND ydate>:"$2":;"}' >> update_closing_price_awk.txt

head -3 update_closing_price_awk.txt
tail -3 update_closing_price_awk.txt
echo "-- This script created by $0" > update_closing_price.sql
grep ':' update_closing_price_awk.txt | sed '1,$s/:/'"'"'/g' >> update_closing_price.sql
echo 'COMMIT;' >> update_closing_price.sql

head -3 update_closing_price.sql
tail -3 update_closing_price.sql

echo I should be able to run
echo update_closing_price.sql
echo now.

echo Oracle:
echo 'sqlplus trade/t @update_closing_price.sql'
echo Postgres:
echo 'psql -f update_closing_price.sql'

exit
