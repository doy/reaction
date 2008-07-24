#!/bin/sh

find lib -type 'f' | egrep -v '/Widget(\.|/)' | xargs perl ~/wdir/reaction/Reaction/0.001/trunk/script/rclass_back_to_moose.pl
