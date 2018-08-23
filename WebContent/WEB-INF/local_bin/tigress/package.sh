#!/bin/bash

echo $1
echo $2
echo $3

rm $2
echo "" > $2
cat $3 >> $2
echo "" >> $2
cat $1 >> $2
