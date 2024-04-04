#!/bin/bash
## 03/07/24
## start spid jupyter

#note that the container already pretty much creates the directories, just make sure to bind `/hpc` and pass --nv to use gpus

#container location
CONTAINER_FULL_PATH='/hpc/apps/spid/master/bin/spid_container.sif'



#noteboook location to launch everything 
SPID_CACHE_DIR=${HOME}/.spid_cache
if ! [ -d ${SPID_CACHE_DIR} ]; then
    mkdir -p ${SPID_CACHE_DIR}
fi

NOTEBOOK_ROOT=${MYDATA}

function create_random_port () 
{

    local MAX_PORT=65535
    local SET_PORT_START=60000

    PORT_DIFFERENCE=$((${MAX_PORT} - ${SET_PORT_START}))
    VALS=($(seq 60000 65535))

    echo ${VALS[$((($RANDOM + $PORT_DIFFERENCE) % 5535))]}

}



MY_PORT=$(create_random_port)

# create server config
export CONFIG_FILE="${PWD}/config.py"
(
umask 077
cat > "${CONFIG_FILE}" << EOL
c.NotebookApp.ip = '*'
c.NotebookApp.port = ${MY_PORT}
c.NotebookApp.port_retries = 0
c.NotebookApp.allow_origin = '*'
c.NotebookApp.notebook_dir = "${NOTEBOOK_ROOT}"
c.NotebookApp.disable_check_xsrf = True
EOL
)





# Cache directory for overlay creation embedded into the container. 
export SPID_USER_HAX=$(basename $HOME)
export SPID_CACHE_DIR_NAME=spid_cache
export SPID_USER_HOME_CACHE_DIR=${HOME}/${SPID_CACHE_DIR_NAME}
export SPID_USER_MYDATA_CACHE_DIR=/hpc/mydata/${SPID_USER_HAX}/${SPID_CACHE_DIR_NAME}


#check to see if our hpc directory exists, then make sure to generate cache directory for user
set -x 
PREFERRED_CACHE_DIR=${SPID_USER_MYDATA_CACHE_DIR}

if [ -d '/hpc' ]
then
    PREFERRED_CACHE_DIR=${SPID_USER_MYDATA_CACHE_DIR}
else
    PREFERRED_CACHE_DIR=${SPID_USER_HOME_CACHE_DIR}
fi


if ! [ -d ${PREFERRED_CACHE_DIR} ]
then
    #make the user directory
    mkdir -p ${PREFERRED_CACHE_DIR}
fi


if ! [ -d ${PREFERRED_CACHE_DIR}/overlay ]
then
    #make the user directory
    mkdir -p ${PREFERRED_CACHE_DIR}/overlay
fi



# Look at adding more to the depot directory. 


####
export PREFERRED_CACHE_DIR


echo "Starting SPID Container w/ Jupyter Notebook"

apptainer exec --overlay ${PREFERRED_CACHE_DIR}/overlay --nv --bind /hpc:/hpc ${CONTAINER_FULL_PATH} jupyter notebook --config="${CONFIG_FILE}"


#apptainer shell --overlay ${PREFERRED_CACHE_DIR}/overlay --nv --bind /hpc:/hpc ${CONTAINER_FULL_PATH}

# mkdir -p /tmp/rc_overlay_dir

#apptainer shell --overlay /tmp/rc_overlay_dir --bind /hpc:/hpc ${CONTAINER_FULL_PATH}



exit 0 


