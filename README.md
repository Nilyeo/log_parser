## Log Parser

a QNAP diagnostic log parser, tested on macOS 13.2 / GNU bash version 3.2.57 

### Usage

sh log_parser.sh [folder_name_without space]  \
for example:\
sh log_parser.sh Q211I009382

### When you can use 

Quickly navigate the following information

* Error/Warning is detected

  The apps provides a notification when the following error/warning are found

  * Disk Warning/ Error
  * ATA bus / IO / media  error in kernel log
  * Fcorig warning
  * Call Trace 
  * PSTORE 
  * Pool Error (-M-)
  * Unknown device in PVS 
  * Pool Read/Delete Status

* Header provides the following information

  * The information to know how long the log was collected
  * Helpdesk app version
  * NAS model
  * Serial Number
  * Firmware version
  * myQNAPcloud URL 
  * Power on time when the log was collected
  * The information to know if the NAS is migrated.

* Basic information

  * Server Name
  * Web Management Port
  * The information to know 
    * SSH is enabled or not, and use which port
    * Telnet is enabled or not, and use which port
    * 2-step-verification is enabled or not
    * Connection log is enabled or not
    * Wake on LAN is enabled or not
    * Disk Standby mode is enabled or not
    * Alarm is enabled or not
    * NTP server is enabled or not
    * SSL is enabled or not.

* APP information

  * Installed Apps

* System log information

  * Color the system log for different level
  * Shorten the system log with essential info only
  * Classify the system for different function
  * Collect abnormal rebooting system log
  * Collect firmware upgrading system log



