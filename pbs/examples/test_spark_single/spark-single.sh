#!/usr/bin/env bash

#PBS -N SparkPi
#PBS -l select=1:ncpus=4:mem=2gb
#PBS -l walltime=0:20:00

cd $PBS_O_WORKDIR

# Manually define PBS_NUM_PPN as same as ppn=xx
PBS_NUM_PPN=4

# Manually set how much memory allocated to each spark worker/driver.
# It must be equal to PBS -l mem=xx but do not use "mb" or "gb"
SPARK_MEM="2g" # just m, M, g or G 

# Change the relative path "$SPARK_HOME/examples/jars/spark-examples_${SPARK_VERSION}.jar"
# to that corresponding to your specific Spark version and instalation paths.
SPARK_VERSION="2.11-2.3.0"
$SPARK_HOME/bin/spark-submit --master local[$PBS_NUM_PPN] --class org.apache.spark.examples.SparkPi --driver-memory $SPARK_MEM $SPARK_HOME/examples/jars/spark-examples_${SPARK_VERSION}.jar 40 > $PBS_O_WORKDIR/pi.txt
