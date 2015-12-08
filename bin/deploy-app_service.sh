#!/bin/bash
set -e

SERVICE=app_service
REMOTE=https://github.com/TheSEED
BRANCH=master
# following is pre-nov-2015 release
#BRANCH=27a98a3717671e4372785e08bc61e0d02fe2fa2f

DEV_CONTAINER=/disks/p3/dev_container
AUTO_DEPLOY_CFG=auto-deploy.cfg

TARGET=/disks/p3/deployment


pushd $DEV_CONTAINER
. user-env.sh

pushd modules

rm -rf $SERVICE
git clone $REMOTE/$SERVICE
if [ $? -ne 0 ] ; then 
	echo "problem running git  lone $REMOTE/$SERVICE"
	exit 1
fi

pushd $SERVICE

git checkout $BRANCH 
if [ $? -ne 0 ] ; then
	echo "problem running git checkout $BRANCH"
        exit 1
fi

rsync -e "ssh -i /disks/p3/.ssh/id_p3_redwood" -arv --delete . redwood:$DEV_CONTAINER/modules/$SERVICE/.
ssh -i /disks/p3/.ssh/id_p3_redwood redwood ". $DEV_CONTAINER/user-env.sh; cd $DEV_CONTAINER/modules/$SERVICE/.; make" | sed 's/^/REDWOOD> /'

make
if [ $? -ne 0 ] ; then
	echo "problem running make"
        exit 1
fi


popd 
popd

ssh -i /disks/p3/.ssh/id_p3_redwood redwood ". $DEV_CONTAINER/user-env.sh; \
	cd $DEV_CONTAINER/; perl auto-deploy deploy.cfg --module $SERVICE" | sed 's/^/REDWOOD> /'

perl auto-deploy $AUTO_DEPLOY_CFG -module $SERVICE
if [ $? -ne 0 ] ; then
	echo "problem running perl auto-deploy $AUTO_DEPLOY_CFG -module $SERVICE"
        exit 1
fi


set +e
echo "stopping service"
$TARGET/services/$SERVICE/stop_service
set -e

sleep 5 

echo "starting service"
$TARGET/services/$SERVICE/start_service
if [ $? -ne 0 ] ; then
	echo "problem running $TARGET/services/$SERVICE/start_service"
        exit 1
fi

sleep 5

pushd modules/$SERVICE
make test
