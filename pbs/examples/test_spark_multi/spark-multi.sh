#!/bin/bash

#PBS -l select=3:ncpus=2:mem=2gb:vmem=2gb
#PBS -l place=scatter
#PBS -l walltime=0:20:00
#PBS -N SparkPiMulti

# -l select must be greater than 1. Support only 1 node spec (no + sign).
# -l vmem set the maximum memory for each spark worker process 
# -l place=scatter tries to allocate different machines/nodes as much as possible

# Manually define PBS_NUM_PPN as same as select=x
export PBS_NUM_PPN=3
export SPARK_JOB_DIR=$PBS_O_WORKDIR
# Set SPARK_WORKER_MEMORY the same as vmem but without the ending 'b' of bytes
export SPARK_WORKER_MEMORY='2g' # just m, M, g or G 

# Create/append spark configuration in SPARK_JOB_DIR from PBS environments. 
# Specific spark configuration can be put into the SPARK_JOB_DIR/conf/* a priori.
# If existing configuration is found SPARK_JOB_DIR/conf/*, spark-on-hpc.sh will
#   append its auto-generated section. 
# If rerun the job, delete the auto-generated section first
$SPARK_HOME/sbin/spark-on-hpc.sh config || { exit 1; }

# Start a spark cluster inside HPC using PBS -l nodes=xx.  
# One node will be dedicated to the master. The rest nodes are workers. 
$SPARK_HOME/sbin/spark-on-hpc.sh start

# Import several spark variables
source $SPARK_HOME/sbin/spark-on-hpc.sh vars

SPARK_URL=spark://$SPARK_MASTER_IP:$SPARK_MASTER_PORT
WEBUI_URL=http://$SPARK_MASTER_IP:$SPARK_MASTER_WEBUI_PORT
 
# The driver and executor memory are defined internally from SPARK_WORKER_MEMORY.
# Change the relative path "$SPARK_HOME/examples/jars/spark-examples_${SPARK_VERSION}.jar"
# to that corresponding to your specific Spark version and instalation paths.
SPARK_VERSION="2.11-2.3.0"
$SPARK_HOME/bin/spark-submit --master $SPARK_URL --class org.apache.spark.examples.SparkPi $SPARK_HOME/examples/jars/spark-examples_${SPARK_VERSION}.jar 40 > $PBS_O_WORKDIR/pi.txt

# Stop the spark cluster
$SPARK_HOME/sbin/spark-on-hpc.sh stop
