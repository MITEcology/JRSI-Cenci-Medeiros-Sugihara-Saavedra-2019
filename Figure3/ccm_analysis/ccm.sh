#!/bin/bash

declare -a sample2=('divergence,temperature' 'divergence,Waves')
var=2
for j in "${sample2[@]}"
do
	Rscript main.R $j $var 1
	echo 'done'
done
