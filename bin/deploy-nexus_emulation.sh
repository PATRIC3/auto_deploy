#!/bin/bash
SERVICE=nexus_emulation
REMOTE=https://github.com/kbase
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
	echo "BUILD ERROR: problem running git clone $REMOTE/$SERVICE"
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


# no tests for this currently
exit

sleep 5

pushd modules/$SERVICE
make test
if [ $? -ne 0 ] ; then
        echo "BUILD ERROR: problem running make test"
        exit 1
fi
