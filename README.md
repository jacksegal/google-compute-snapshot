# Google Compute Engine Snapshot

## Overview
* Takes daily snapshot of primary disk without any user input
* Deletes all snapshots that are older than 7 days

## Prerequisite
* cURL must be installed

## Limitations
* Only works for the primary disk on VM

## Setup
* I run the script from cron: `0 05 * * * root sh /1/snapshot.sh >> /var/log/cron/snapshot.log 2>&1`
* I created the `var/log/cron` directory for all of my cron outputs
* I added the folder to logrotate: `/etc/logrotate.d/cron`

```/var/log/cron/*.log {
     daily
     missingok
     rotate 14
     compress
     notifempty
     create 640 root adm
     sharedscripts
 }```