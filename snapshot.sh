#!/usr/bin/env bash
export PATH=$PATH:/usr/local/bin/:/usr/bin

usage() {
  echo -e "\nUsage: $0 [-d <days>]" 1>&2
  echo -e "\nOptions:\n"
  echo -e "    -d    Number of days to keep snapshots.  Snapshots older than this number deleted."
  echo -e "          Default if not set: 7 [OPTIONAL]"
  echo -e "\n"
  exit 1
}

#
# Get and set how long to keep snapshots. Default to 7 (days)
#
while getopts ":d:" o; do
  case "${o}" in
    d)
      opt_d=${OPTARG}
      ;;

    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [[ -n $opt_d ]];then
  OLDER_THAN=$opt_d
else
  OLDER_THAN=7
fi

#
# CREATE DAILY SNAPSHOT
#
# get the device name for this vm
DEVICE_NAME="$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/disks/0/device-name" -H "Metadata-Flavor: Google")"

# get the device id for this vm
DEVICE_ID="$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/id" -H "Metadata-Flavor: Google")"

# get the zone that this vm is in
INSTANCE_ZONE="$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")"

# strip out the zone from the full URI that google returns
INSTANCE_ZONE="${INSTANCE_ZONE##*/}"

# create a datetime stamp for filename
DATE_TIME="$(date "+%s")"

# create the snapshot
echo -e "[$(date -Iseconds)] \c"
echo -e "$(gcloud compute disks snapshot ${DEVICE_NAME} --snapshot-names gcs-${DEVICE_NAME}-${DEVICE_ID}-${DATE_TIME} --zone ${INSTANCE_ZONE})"


#
# DELETE OLD SNAPSHOTS (OLDER THAN 7 DAYS)
#

# get a list of existing snapshots, that were created by this process (gcs-), for this vm disk (DEVICE_ID)
SNAPSHOT_LIST="$(gcloud compute snapshots list --regexp "(.*gcs-.*)|(.*-${DEVICE_ID}-.*)" --uri)"

# loop through the snapshots
echo "${SNAPSHOT_LIST}" | while read line ; do

   # get the snapshot name from full URL that google returns
   SNAPSHOT_NAME="${line##*/}"

   # get the date that the snapshot was created
   SNAPSHOT_DATETIME="$(gcloud compute snapshots describe ${SNAPSHOT_NAME} | grep "creationTimestamp" | cut -d " " -f 2 | tr -d \')"

   # format the date
   SNAPSHOT_DATETIME="$(date -d ${SNAPSHOT_DATETIME} +%Y%m%d)"

   # get the expiry date for snapshot deletion (currently 7 days)
   SNAPSHOT_EXPIRY="$(date -d "-${OLDER_THAN} days" +"%Y%m%d")"

   # check if the snapshot is older than expiry date
    if [ $SNAPSHOT_EXPIRY -ge $SNAPSHOT_DATETIME ];then
      # delete the snapshot
      echo -e "[$(date -Iseconds)] \c"
      printf 'y\n' | gcloud compute snapshots delete ${SNAPSHOT_NAME}
    fi
done
