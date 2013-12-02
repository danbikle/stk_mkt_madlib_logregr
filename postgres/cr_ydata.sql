--
-- ~/tv/postgres/cr_ydata.sql
--

-- I use this script to create table ydata which holds price data from
-- yahoo.  Note that this Postgres syntax is different than the syntax
-- I use for Oracle.


CREATE TABLE ydata
(
tkr VARCHAR(9)
,ydate   DATE
,opn     DECIMAL
,mx      DECIMAL
,mn      DECIMAL
,closing_price DECIMAL
,vol     DECIMAL
,adjclse DECIMAL
,closing_price_orig DECIMAL
)
;
