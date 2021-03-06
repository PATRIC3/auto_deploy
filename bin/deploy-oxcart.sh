#!/bin/bash
SERVICE=oxcart
REMOTE=https://github.com/patric3
BRANCH=master

DEV_CONTAINER=/disks/p3/dev_container
AUTO_DEPLOY_CFG=auto-deploy.cfg

TARGET=/disks/p3/deployment


pushd $DEV_CONTAINER
. user-env.sh

pushd modules

rm -rf $SERVICE
git clone --recursive $REMOTE/$SERVICE
if [ $? -ne 0 ] ; then 
	echo "BUILD ERROR: problem running git  lone $REMOTE/$SERVICE"
	exit 1
fi

pushd $SERVICE

git checkout $BRANCH 
if [ $? -ne 0 ] ; then
	echo "BUILD ERROR: problem running git checkout $BRANCH"
        exit 1
fi

make
if [ $? -ne 0 ] ; then
	echo "BUILD ERROR: problem running make"
        exit 1
fi

popd 
popd

perl auto-deploy $AUTO_DEPLOY_CFG -module $SERVICE
if [ $? -ne 0 ] ; then
	echo "BUILD ERROR: problem running perl auto-deploy $AUTO_DEPLOY_CFG -module $SERVICE"
        exit 1
fi


# echo "stopping service"
 #$TARGET/services/$SERVICE/stop_service

# sleep 5 

# echo "starting service"
# $TARGET/services/$SERVICE/start_service
# if [ $? -ne 0 ] ; then
# 	echo "BUILD ERROR: problem running $TARGET/services/$SERVICE/start_service"
#         exit 1
# fi

# sleep 5

# pushd modules/$SERVICE
# make test
