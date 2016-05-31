# Google Compute Engine Snapshot

## Overview
* Takes daily snapshot of primary disk without any user input
* Deletes all snapshots that are older than 7 days

## Prerequisite
* cURL must be installed
* The VM must have the sufficient gcloud permissions, including "compute" set to "enabled": http://stackoverflow.com/questions/31905966/gcloud-compute-list-networks-error-some-requests-did-not-succeed-insufficie#31928399

## Limitations
* Only works for the primary disk on VM

## Setup
* I run the script from cron.d: `0 05 * * * root sh /1/snapshot.sh >> /var/log/cron/snapshot.log 2>&1`
* I created the `var/log/cron` directory for all of my cron outputs
* I added the `var/log/cron` directory folder to logrotate: `/etc/logrotate.d/cron`

```/var/log/cron/*.log {
     daily
     missingok
     rotate 14
     compress
     notifempty
     create 640 root adm
     sharedscripts
 }```
 
## Downloading the script and opening in Windows?
 * If you download the script and open it on a Windows machine, that may add windows character's to the file: https://github.com/Forward-Action/google-compute-snapshot/issues/1.
