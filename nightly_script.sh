#/bin/bash

#this script kicks off the dashboard on eureka

#make sure we have dependencies satisifed
#for some reason my env won't consistently get soft or resoft so force it
export SOFTENV_ALIASES=/software/common/adm/softenv/etc/softenv-aliases.sh
source ${SOFTENV_ALIASES}
soft add +cmake-2.8.9
soft add +git-1.7.6.4
soft add +gcc 
soft add +mpich2-1.3.1-gnu 
soft add +boost
resoft

T0=`date`
LOGFILE="/intrepid-fs0/projects/pvdev/common/dashboardscripts/nightly_eureka_log.txt"
rm -f $LOGFILE
echo "START AT  $T0" > $LOGFILE

echo "-D dirname:=${1:-nightly-next}"
echo "------------------------------------------------" >> $LOGFILE

ctest -VV -S /intrepid-fs0/projects/pvdev/common/dashboardscripts/nightly_script.cmake -D dirname:=${1:-nightly-next} >> $LOGFILE

echo "------------------------------------------------" >> $LOGFILE

echo "START TIME $T0" >> $LOGFILE
echo "END   TIME `date`" >> $LOGFILE
