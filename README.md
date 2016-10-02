# Google (gcloud) Compute Engine Snapshot

## Overview
* Takes a daily snapshot of the primary disk without any user input
* Deletes all snapshots that are older than 7 days (default)
* [OPTIONAL] Snapshots can be kept for > 7 days

        Usage: ./snapshot.sh [-d <days>]

        Options:

           -d  Number of days to keep snapshots. Snapshots older than this number deleted.
               Default if not set: 7 [OPTIONAL]


## Prerequisites
* `cURL` must be installed
* The VM must have the sufficient gcloud permissions, including "compute" set to "enabled":

	[	http://stackoverflow.com/questions/31905966/gcloud-compute-list-networks-error-some-requests-did-not-succeed-insufficie#31928399](http://stackoverflow.com/questions/31905966/gcloud-compute-list-networks-error-some-requests-did-not-succeed-insufficie#31928399)

## Limitations
* Only works for the primary disk on VM
* Only manages snapshots created by the script

## Recommended Setup
* Load the script on to the VM (do not run it from a remote source)
* Create a `/var/log/cron` directory for all `cron` outputs
* Create `/var/log/cron/snapshot.log`
* Change group to "adm":
	
	`# chgrp adm /var/log/cron/snapshot.log`
	
* Change permissions on the "snapshot.log" file:

	`# chmod 664 /var/log/cron/snapshot.log`
	
* Run the script from a cronjob.  Note this must be done as whatever user has access to `gcloud compute` (usually the Google user that created the VM):

        0 05 * * * /path/to/snapshot.sh >> /var/log/cron/snapshot.log 2>&1
      
* Add the `/var/log/cron` directory folder to logrotate: `/etc/logrotate.d/cron`

        /var/log/cron/*.log {
            daily
            missingok
            rotate 14
            compress
            notifempty
            create 640 root adm
            sharedscripts
        }


### Downloading the script and opening in Windows?

If you download the script and open it on a Windows machine, that may add windows character's to the file: https://github.com/Forward-Action/google-compute-snapshot/issues/1.
