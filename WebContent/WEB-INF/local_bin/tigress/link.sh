#!/bin/bash

echo $1
echo $2
echo $3

echo "Cleaning $3"
rm $3
touch $3
echo "" > $3
echo "Adding include $1"
echo "#include $1" >> $3
echo "" >> $3
echo "Adding $2"
cat $2 >> $3
echo $3
