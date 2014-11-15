#!/bin/bash
for i in {1..1000} 
do
	
	DATA=$((1384551711+($RANDOM*962)))
	touch $DATA
	git add $DATA
	git commit --date $DATA -m $DATA
	#echo $DATA+"0000"
	##date --date=@$DATA
done
