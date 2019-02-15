function rand() {
	min=$1
	max=$(($2 - $min + 1))
	num=$(($RANDOM + 1000000000))
	echo $(($num % $max + $min))
}
N=$(rand 1 10000)

G=0

while [ $G != $N ];do
	read -p "Please enter a number: " G
	if [ $G -gt $N ];then
		echo "Please be a little bit small!"
	else
		echo "Please be a bit bigger"
	fi
done

echo "Yes,The Num is $G"
