#!/usr/bin/env bash
export PATH=$PATH:/usr/local/bin/:/usr/bin

#
# CREATE DAILY SNAPSHOT
#

# get the device name for this vm
DEVICE_NAME="$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/disks/0/device-name" -H "Metadata-Flavor: Google")"

# get the zone that this vm is in
INSTANCE_ZONE="$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")"

# strip out the zone from the full URI that google returns
INSTANCE_ZONE="${INSTANCE_ZONE##*/}"

# create a datetime stamp for filename
DATE_TIME="$(date "+%Y%m%d%H%M%S")"

# create the snapshot
echo "$(gcloud compute disks snapshot ${DEVICE_NAME} --snapshot-names ${DEVICE_NAME}-${DATE_TIME} --zone ${INSTANCE_ZONE})"



#
# DELETE OLD SNAPSHOTS (OLDER THAN 7 DAYS)
#

# get a list of existing snapshots
SNAPSHOT_LIST="$(gcloud compute snapshots list --uri)"

# loop through the snapshots
echo "${SNAPSHOT_LIST}" | while read line ; do

   # get the snapshot name from full URL that google returns
   SNAPSHOT_NAME="${line##*/}"

   # get the date that the snapshot was created
   SNAPSHOT_DATETIME="$(gcloud compute snapshots describe ${SNAPSHOT_NAME} | grep "creationTimestamp" | cut -d " " -f 2 | tr -d \')"
   
   # format the date
   SNAPSHOT_DATETIME="$(date -d ${SNAPSHOT_DATETIME} +%Y%m%d)"

   # get the expiry date for snapshot deletion (currently 7 days)
   SNAPSHOT_EXPIRY="$(date -d "-7 days" +"%Y%m%d")"

   # check if the snapshot is older than expiry date
   if [ $SNAPSHOT_EXPIRY -ge $SNAPSHOT_DATETIME ]; 
        then
	 # delete the snapshot
         echo "$(gcloud compute snapshots delete ${SNAPSHOT_NAME} --quiet)"
   fi   
done
