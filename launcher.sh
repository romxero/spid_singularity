#!/bin/bash

#launching the container 
CONTAINER_FULL_PATH='/hpc/apps/spid/master/bin/spid.sif'
MAIN_COMMAND=$(basename $0)
SPID_USER_CACHE_DIR=${HOME}/._spid
SPID_USER_LOGFILE=${SPID_USER_CACHE_DIR}/spid.log

#places to bind
#M_BIND_0=${HOME}


if ! [ -d ${SPID_USER_CACHE_DIR} ]
then
    #make the user directory 
    mkdir -p ${SPID_USER_CACHE_DIR}
fi

#set up logging 
#exec > {SPID_USER_LOGFILE} 2>&1
#set -x #uncomment for debugging 

#main case to look at symlinked programs
case ${MAIN_COMMAND} in

  "jupyter")
    #jupyter apptainer launch
    apptainer exec ${CONTAINER_FULL_PATH} jupyter "$@" 
    ;;

  "container-spid.jl")
    apptainer exec ${CONTAINER_FULL_PATH} spid.jl "$@" 
    ;;

  *)
    echo "The right program didn't run, darn.. : ${MAIN_COMMAND}" 
    exit 1 
    ;;
esac


exit 0 
