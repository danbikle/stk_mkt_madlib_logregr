#!/bin/bash

# ~/tv/cr_logreg_vectors.bash

# I use this script to build vectors for a MADlib-logreg-model.

if [ $# -lt 1 ] ; then
  echo Need 1 boundry date
  echo demo:
  echo $0 2010-01-01
  exit 0
fi

# Get boundry date for model from cmd-line.
# I build the model from dates before the boundry date.
# I intend to predict ticker vectors created after boundry date.
BDATE=$1

~/tv/psqlmad.bash -f ~/tv/cr_logreg_vectors.sql -v BDATE="'$BDATE'"

exit

