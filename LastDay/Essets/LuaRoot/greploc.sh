#!/bin/bash

count=0
Keys=`lua -e "for k,v in pairs(dofile('localize/en.lua')) do print(k) end"`
for k in $Keys; do
    ret=`grep -r $k ui/* | wc -l`
    if [ $ret == "0" ]; then 
        echo $k $ret
        count=`expr $count + 1`
    fi
done 
echo $count
