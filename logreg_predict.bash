#!/bin/bash

# logreg_predict.bash

# I use this script to predict price directions of vectors.
# I depend on a model built by cr_logreg_model.bash
# Both this script and         cr_logreg_model.bash
# are coordinated by many_mad12.bash

if [ $# -lt 2 ] ; then
  echo Need 1 tkr, Need 1 boundry date
  echo demo:
  echo $0 IBM 2013-01-01
  exit 0
fi

TKR=$1
BDATE=$2

# Get boundry date and tkr from cmd-line.
# I build the model from dates before the boundry date.
# I intend to predict ticker vectors created after boundry date.

~/tv/psqlmad.bash -f ~/tv/logreg_predict.sql -v TKR="'$TKR'" -v BDATE="'$BDATE'"

exit

