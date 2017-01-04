#!/bin/bash -x
# copy resized image zip it to image directory
# written by Tim Moody as sent to ghunt June 2016
# assume /dev/sdb2 is partition to be shrunk
# parameter 1 - output file name
# parameter 2 - optional root device partition otherwise /dev/sdb2
# parameter 3 - optional image directory otherwise /curation/images
# Automatically determine a size for the output disk image
# (including root, swap, and boot partitions).
#
# This is calculated by using resize2fs to shrink, then adding the space
# occupied by previous partitions
# Assumes root is last partition
 
if [ $# -eq 0 ]; then
   echo "Usage: $0 filename (no .img), optional rootfs device (like /dev/sdb2), optional image directory (like /curation/images)"
   exit 1
fi

if [ -z $2 ]; then
   PARTITION=/dev/sdb2
else
   PARTITION=$2
fi
 
# create a standard filename yymmdd-$1-<git hash>.img
# fetch the git hash
mount $PARTITION /mnt
pushd /mnt/opt/schoolserver/xsce
HASH=`git describe |cut -d- -f3`
YMD=$(date +%y%m%d)
popd
umount $PARTITION
 
FILENAME=$(printf "%s_%s_%s.img" $YMD $1 $HASH)
 
if [ ! -b $PARTITION ];then
   echo "Device $PARTITION not found".
   exit 1
fi
 
if [ -z $3 ]; then
   IMAGE_DIR=/curation/images
else
   IMAGE_DIR=$3
fi
 
mkdir -p $IMAGE_DIR
cd $IMAGE_DIR
 
umount $PARTITION
umount /media/usb*
 
DEVICE=${PARTITION:0:-1}
 
# recalc last sector and read that many sectors from card
last_sector=`parted -s $DEVICE unit s print |tail -2 |head -1| awk '{print $3}'`
last=${last_sector:0:-1}
last=$(( last / 8  )) # integer division 
last=$(( last + 1  )) # round up
echo "last sector: $last"
dd if=$DEVICE of=$FILENAME bs=4K count=$last status=progress
 
zip $FILENAME.zip $FILENAME
md5sum $FILENAME > $FILENAME.md5.txt
md5sum $FILENAME.zip > $FILENAME.zip.md5.txt
