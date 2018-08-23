#!/bin/bash

TIME=`date +%H%M%S`

if [ $TIME -ge 000000 ] && [ $TIME -lt 035000 ]; then
	sed -i '' '6s/.*/#SBATCH --reservation cembs1/' task.qsub
fi

if [ $TIME -ge 035000 ] && [ $TIME -lt 100000 ]; then
	sed -i '' '6s/.*/#SBATCH --reservation cembs2/' task.qsub
fi

if [ $TIME -ge 100000 ] && [ $TIME -lt 155000 ]; then
	sed -i '' '6s/.*/#SBATCH --reservation cembs3/' task.qsub
fi

if [ $TIME -ge 155000 ] && [ $TIME -lt 220000 ]; then
	sed -i '' '6s/.*/#SBATCH --reservation cembs4/' task.qsub
fi

if [ $TIME -ge 220000 ] && [ $TIME -le 235959 ]; then
	sed -i '' '6s/.*/#SBATCH --reservation cembs1/' task.qsub
fi