set -x

TARGET=/disks/p3/deployment
DISTRO=/disks/p3/distro
TMP=/disks/p3/tmp

/usr/bin/rsync -ar --exclude services $TARGET $TMP/
if [ $? -ne 0 ] ; then 
	echo "BUILD ERROR: problem running /usr/bin/rsync -ar $TARGET $TMP/"
	exit 1
fi

pushd $TMP

/bin/tar -cf deployment.tar deployment
if [ $? -ne 0 ] ; then 
	echo "BUILD ERROR: problem running /bin/tar -cvf deployment.tar deployment"
	exit 1
fi

/bin/cp deployment.tar $DISTRO/
if [ $? -ne 0 ] ; then 
	echo "BUILD ERROR: problem running /bin/cp deployment.tar $DISTRO/"
	exit 1
fi

/bin/rm -rf deployment deployment.tar
