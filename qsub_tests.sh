#/bin/bash

#qsub a job that runs NightlyTest on the compute nodes and wait for it 
SCRIPT_DIR=$1
BUILD_DIR=$2
BUILD_NAME=$3
SITE=$4

T0=`date`
echo $T0
jobnum=`cqsub -e DISPLAY=:0.0 -n 2 -t 20 ${SCRIPT_DIR}/compute_node_tests.sh ${BUILD_DIR} 2>&1 | tail -n 1`
echo $jobnum

sleep 5
echo "WAITING FOR $jobnum"
cqwait $jobnum

echo $T0
date
echo "DONE TESTING"

echo "FIXUP test stage jobname"
#There must be some way to get ctest to choose the same buildname and name
#but I couldn't find it, so I'm taking matters into my own hands.
#Otherwise the dashboard submission for the test stage shows up on
#a different row from the rest as if from some unrelated machine.
cd $BUILD_DIR
sed -i.original -e 's|BuildName=".*"|BuildName="'${BUILD_NAME}'"|' Testing/*/Test.xml
sed -i.original -e 's|\tName=".*"|\tName="'${SITE}'"|' Testing/*/Test.xml
#cmake gets the build stamp right fortunately
