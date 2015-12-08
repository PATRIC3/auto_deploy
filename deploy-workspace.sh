#!/bin/bash
SERVICE=Workspace
REMOTE=https://github.com/patric3
BRANCH=master

DEV_CONTAINER=/disks/p3/dev_container
AUTO_DEPLOY_CFG=auto-deploy.cfg

TARGET=/disks/p3/deployment


pushd $DEV_CONTAINER
. user-env.sh

pushd modules

rm -rf $SERVICE
git clone $REMOTE/$SERVICE
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


echo "stopping service"
$TARGET/services/$SERVICE/stop_service

sleep 5 

echo "starting service"
$TARGET/services/$SERVICE/start_service
if [ $? -ne 0 ] ; then
	echo "BUILD ERROR: problem running $TARGET/services/$SERVICE/start_service"
        exit 1
fi

sleep 5

# TEST the module. This section is under development

source /disks/p3/deployment/user-env.sh
pushd modules/$SERVICE

# perl t/client-tests/ws.t
# if [ $? -ne 0 ] ; then
#         echo "BUILD ERROR: problem running make test"
#         exit 1
# fi

perl t/client-tests/min.t
if [ $? -ne 0 ] ; then
        echo "BUILD ERROR: problem running make test"
        exit 1
fi

perl t/client-tests/create.t
if [ $? -ne 0 ] ; then
        echo "BUILD ERROR: problem running make test"
        exit 1
fi

# perl t/client-tests/create_subdir.t
# if [ $? -ne 0 ] ; then
#         echo "BUILD ERROR: problem running make test"
#         exit 1
# fi

# perl t/client-tests/create_upload_node.t
# if [ $? -ne 0 ] ; then
#         echo "BUILD ERROR: problem running make test"
#         exit 1
# fi

# perl t/client-tests/upload_to_node.t
# if [ $? -ne 0 ] ; then
#         echo "BUILD ERROR: problem running make test"
#         exit 1
# fi
