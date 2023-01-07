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

* Basic information

  * How long the log was collected
  * Helpdesk app version
  * Serial Number
  * Firmware version
  * myQNAPcloud URL
  * Power on time (when the log was collected)

* APP information

  * Installed Apps

* System log information

  * Color the system log for different level
  * Shorten the system log with essential info only
  * Classify the system for different function
  * Collect abnormal rebooting system log
  * Collect firmware upgrading system log



