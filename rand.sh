#!/bin/bash
### ex:
### ./rand.sh 100 200

function rand() {
	min=$1
	max=$(($2 - $min + 1))
	num=$(($RANDOM + 1000000000)) #增加一个10位数再求余
	echo $(($num % $max + $min))
}

rnd=$(rand $1 $2)
echo $rnd

exit 0
