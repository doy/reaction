#!/bin/sh

find lib -type 'f' | egrep -v '/Widget(\.|/)' | xargs perl script/rclass_back_to
