#! /bin/sh

#This step runs on the compute nodes inside a qsubbed reservation.
#I exclude the tests that just validate source since jobs cost time and only
#interested in whether executables we run in parallel work on this machine.
#Other dashboards can cover the rest

echo "BUILD DIR IS $1"

cd $1
ctest -M Nightly -T Test -L PARAVIEW -E "Header|PrintSelf" 
