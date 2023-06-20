## Log Parser

A diagnostic log parser, tested on macOS 13.2 / GNU bash version 3.2.57 

### Usage

sh log_parser.sh [folder_name_without space]  \
for example:\
sh log_parser.sh Q211I009382

### Best Practice

1. Collect QTS/QuTS hero firmware version in header, Input 4 > 1 to list installed APPs for submitting Mantis
2. Input 7 > 6 to see the system log in short form and with color highlighted
3. Input 7 > 1 and input the keyword to filter the system log.


### Function overview

Quickly navigate the following information

* Error/Warning is detected
  the apps provides a simple notification when an error is detected

  * Disk Warning/ Error
  * ATA bus / IO / media  error in kernel log
  * Fcorig warning
  * Call Trace 
  * PSTORE 
  * Pool Error (-M-)
  * Unknown device in PVS 
  * Pool Read/Delete Status
  * WOL (eth0 missing)

* Header provides the following information

  * The information to know
    * How long the log was collected
    * If the NAS is migrated (if the source and destination model name is different)
  * Helpdesk app version
  * NAS model
  * Firmware version
  * myQNAPcloud URL (if myQNAPcloud is configured)
  * Power on time when the log was collected

1. Basic information
   * Server Name
   * Web Management Port
   * The information to know the following options are enabled or not.
     * SSH, and use which port
     * Telnet, and use which port
     * 2-step-verification
     * Connection log 
     * Wake on LAN
     * Disk Standby mode 
     * Alarm Buzzer
     * NTP server
     * HTTPS
2. APP information
   * Installed Apps
     * App name
     * Author
     * Enable
     * Version
     * Status
     * Date
3. Disk information

   * qli_storage -d
   * SMART information
     * Disk model
     * Read Speed
     * SMART value
   * Expansion cards or units
4. Shared Folders information
5. System log information

   * Color the system log for different level
   * Shorten the system log with essential info only
   * Classify the system for different function
   * Collect abnormal rebooting system log
   * Collect firmware upgrading system log
6. Kernel log information
7. Network information
   * ifconfig
   * route
   * outgoing log
   * gateway policy

8. Memory information

9. myQNAPcloud information

