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
pushd $SERVICE

# TEST the module. This section is under development

echo "deleting mongo database"
mongo WorkspaceBuild --eval "db.dropDatabase()"

echo "deleting db-path"
rm -r /disks/p3/workspace/P3WSDB/

source /disks/p3/deployment/user-env.sh
pushd modules/$SERVICE

perl t/client-tests/ws.t
if [ $? -ne 0 ] ; then
        echo "BUILD ERROR: problem running make test"
        exit 1
fi

perl t/client-tests/create.t
if [ $? -ne 0 ] ; then
        echo "BUILD ERROR: problem running make test"
        exit 1
fi

perl t/client-tests/create_subdir.t
if [ $? -ne 0 ] ; then
        echo "BUILD ERROR: problem running make test"
        exit 1
fi

perl t/client-tests/create_upload_node.t
if [ $? -ne 0 ] ; then
        echo "BUILD ERROR: problem running make test"
        exit 1
fi

perl t/client-tests/upload_to_node.t
if [ $? -ne 0 ] ; then
        echo "BUILD ERROR: problem running make test"
        exit 1
fi
