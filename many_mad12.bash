#!/bin/bash

# ~/tv/many_mad12.bash

# I use this script to run logistic regression,
# many times

cd ~/tv/

# Drop table predictions12.
# I intend to fill it with a fresh set of predictions and then report from it.

./psqlmad.bash<<EOF
DROP TABLE predictions12;
EOF

# Boundry Date:
export BDATE=2010-01-01

# Create/Train the Logistic Regression model
./cr_logreg_vectors.bash $BDATE

# Now I predict.
# Ensure that vector and prediction call both have same boundry date on the command line.

./logreg_predict.bash  SPY $BDATE
./logreg_predict.bash  BA  $BDATE
./logreg_predict.bash  CAT $BDATE
./logreg_predict.bash  CVX $BDATE
./logreg_predict.bash  DD  $BDATE
./logreg_predict.bash  DIS $BDATE
./logreg_predict.bash  ED  $BDATE
./logreg_predict.bash  GE  $BDATE
./logreg_predict.bash  HON $BDATE
./logreg_predict.bash  HPQ $BDATE
./logreg_predict.bash  IBM $BDATE
./logreg_predict.bash  JNJ $BDATE
./logreg_predict.bash  KO  $BDATE
./logreg_predict.bash  MCD $BDATE
./logreg_predict.bash  MMM $BDATE
./logreg_predict.bash  MO  $BDATE
./logreg_predict.bash  MRK $BDATE
./logreg_predict.bash  MRO $BDATE
./logreg_predict.bash  NAV $BDATE
./logreg_predict.bash  PG  $BDATE
./logreg_predict.bash  XOM $BDATE


./psqlmad.bash -f ~/tv/qry_predictions12.sql


