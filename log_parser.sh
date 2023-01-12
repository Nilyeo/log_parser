# curl -L https://www.dropbox.com/s/co56ijttb88rqdh/log_parser.sh -o log_parser.sh
# Usage: sh log_parser.sh [folder_name]
# for example: 
# sh log_parser.sh Q211I009382
# !/bin/sh

######################################
# log_parser                         #
# QNAP Diagnostic Log Parser         #
# Joey Lin 2022-07-27                #
# Qnap Systems, Inc.                 #
# Written and Tested on macOS 12.3   #
# 2022-08-11        
# * initial reliease 
# * Add ZFS informaiton
# * Add the funcion to collect some value from uLinux.conf as variables
# 2022-08-12
# * Add the funcion to collect some value from qpkg.conf as variables
# * Add the funcion to collect some value from eclousure0.conf as variable
# * Add the funcion to display SMART info per disk orders, learned using awk to standard the output with fixed width
# 2022-08-15
# * Catch myQNAPcloud variables
# * namp myQNAPcloud DDNS address
# * add the function to read qlvm.conf and RAID.conf
# 2022-08-16
# * parsing qlvm.conf and RAID.conf using awk
# 2022-08-17
# * enhacing system log and kernel log search function
# * add dumpping by which version of helpdesk
# * Sort app name by alphabet
# * add mdadm -E info using sed (sed -n '/\=\=\=\=/q;p) and previous defined disk variables
# * dump memory info using sed and using tab(\t) as grep keyword to find memory module Size
# * enhacing RAID info display
# 2022-08-18
# * parsing if NAS is migrated uisng sort -u, some case can't be judged like TS-212 to TS-431P or TS-412 to TS-539
# * Translate hour to year-month-days for power on hours to each disk SMART info
# * Parsing file system and volume
# 2022-08-19
# * Enhacing reading RAID.conf volume.conf qlvm.conf
# * add helpdesk infomration
# * add power on time determined from last kernel log
# * add WAN IP updated from the NAS
# 2022-08-21
# * parsing ssdcache.conf
# 2022-08-22
# * add error checking function
# 2022-08-23
# * add no input detect
# * get last app list
# * get planform in qpkg.conf under notification center
# 2022-08-25
# * to do: parsing HBS log 
# * to do: Online version 
# 2022-08-26
# * advanced volume info
# * add loading progress
# 2022-08-29
# * add Disk warning parsing
# * grep md in kernel log
# 2022-08-30
# * add curl timeout
# * Trying to do stunnel judgement
# 2022-09-02
# * to view snapshot setting.
# * free TP size = X x (10000-y)/y x 512 /1024/1024
# 2022-09-05
# * add date on error detecting
# * add photo Station update history
# * calculate remain pool size (buggy)
# 2022-09-05
# * myqnapcloud checking DDNS is enabled
# * fcorgie error checking
# 2022-09-12
# * Collect Memory size boot up history used for checking if memory is replaced.
# * cat ve($)t(^tab)
# 2022-12-02
# * to do .russian model show D4 Rev-B, in /etc/hal.conf:model = TS-431K, real model can be found
# 2022-12-6
# * Seperate system log and access log
# 2022-12-14
# *  Add call trace detection and happened date in kernel log 
# 2022-12-19
# * Check highest and lowest SMB version in smb.conf
# 2022-12-20
# * add latset app can be installed on the NAS 
# 2022-12-21
# * Checking guest access 
# * Get external device
# * cat pstore file
# 2022-12-24
# * add 41 and 11 command for tiny system log
# * add colorsys function
# * get zfsgetall
# 2022-12-26
# * Calculate zfs used pool size
# * enhance network informaiton.
# * eth0 check
# * add k and s command
# 2022-12-27
# * add momery upgrade checking
# * mounted data checking
# 2022-12-28
# * using seq Num1 Num2 to list volume number > using awk to list zfs_info in $1  
# * add specif rule to list Storage / HBS / cache setting in system log
# 2022-12-29
# * check on which pool
# * mounted data checking
# 2023-01-05
# * update qcli_storage -d
# * update md_checker
# 2023-01-06
# * Parse volume type using /lvm/backup
# * update ifconfig parsing
# 2023-01-11
# * modifying the codes to apply on macOS and QTS. for example: alias
# * found that sed using " " in macOS and using \s in QTS, need to update md_checker and qcli_storage.
######################################



#runningonQNAPornot(){

ls /etc/config 1>/dev/null 2>&1
if [ $? -ne 0 ]
then


onQNAP=0
  :
  
else
alias grep="busybox grep"
alias sort="busybox sort"

onQNAP=1
fi

#}


press_enter(){
printf "\n"
echo Press enter to process:
read anything
clear
}

progress_bar(){
clear    
echo $progress


}

Generate_logs(){
LPP=$Path/logparser	
LP_QPKGCFG=$Path/etc/config/qpkg.conf
mkdir -p $LPP 

## generate variables
rm -f $LPP/.variables.tmp 
echo \#\#\ basic_info |tee $LPP/.variables.tmp 1>/dev/null 2>&1
## Basic info from html
grep ^Date: $Path/Q*.html -A 13 | sed 's/:\ /=/g'  | sed 's/ //g' | sed -e 's/^/lp_/' |tee -a $LPP/.variables.tmp 1>/dev/null 2>&1
echo \#\#\ basic_info_from uLinux.conf |tee -a $LPP/.variables.tmp 1>/dev/null 2>&1
## Basic info from uLlinux
cat $Path/etc/config/uLinux.conf \
| grep -e "Web Access Port" -e "SSH Enable" -e "SSH Port" -e "TELNET Enable" -e "HomeLink" -e "ACL Enable" -e "Init ACL" \
-e "2 step verification" -e "Auto PowerOn" -e "Write Connection Log" -e "Server Name" -e "Latest Check Live Update" \
-e "Latest Live Update" -e "Enable NTP Server" -e "Disk StandBy Timeout Enable" -e "Disk StandBy Timeout"  \
-e"Buzzer Warning Enable" -e "Wake On Lan" -e "TELNET Port" \
| sed 's/:\ /=/g'  | sed 's/ //g' | sed -e 's/^/lp_/' |tee -a $LPP/.variables.tmp 1>/dev/null 2>&1

## grep Stunnel from uLinux.conf
#grep -i Stunnel -A 3 $Path/etc/config/uLinux.conf | tee -a $LPP/stunnel
grep Stunnel -A 4 $Path/etc/config/uLinux.conf | sed -n '/el\]/,$p' | grep -v Stun |sed -n '/\[/q;p' > $LPP/stunnel   ##beforeafter


## myQNAPcloud info from qid.conf

echo \#\#\ myQNAPcloud_info from qid.conf|tee -a $LPP/.variables.tmp 1>/dev/null 2>&1
cat $Path/etc/config/qid.conf |grep -e "DEVICE NAME" -e "QID" -e DEVICE_ACCESS_CONTROL_MODE | sed 's/:\ /=/g'  | sed 's/ //g' | sed -e 's/^/lp_/' |tee -a $LPP/.variables.tmp 1>/dev/null 2>&1

## get platform from qpkg.conf
echo \#\#\ planform from qpkg.conf|tee -a $LPP/.variables.tmp 1>/dev/null 2>&1
cat $Path/etc/config/qpkg.conf | grep platform | sed 's/ //g' | sed -e 's/^/lp_/' |tee -a $LPP/.variables.tmp 1>/dev/null 2>&1






chmod 755 $LPP/.variables.tmp
source $LPP/.variables.tmp





## QTS or QuTS hero
if grep -q "h" <<< "$lp_Firmware"; then
    lp_ft="QuTS hero"
else
   lp_ft="QTS"
fi


progress="1/5, loading app information"
progress_bar




## generate App variables

lp_AppNumber=$(cat $LP_QPKGCFG | grep -i display_name |wc -l)
lp_AppName=(echo `cat $LP_QPKGCFG | grep -i display_name | sed 's/ //g' | sed 's/Display\_Name\=//g'`)
lp_AppVersion=(echo `cat $LP_QPKGCFG | grep -w Version | sed 's/ //g' | sed 's/Version\=//g'`)
lp_App_Author=(echo `cat $LP_QPKGCFG | grep -w Author | sed 's/ //g' | sed 's/Author\=//g'`)
lp_App_Enable=(echo `cat $LP_QPKGCFG | grep -w Enable | sed 's/ //g' | sed 's/Enable\=//g'`)
lp_App_Date=(echo `cat $LP_QPKGCFG | grep -w Date | sed 's/ //g' | sed 's/Date\=//g'`)
lp_APP_Status=(echo `cat $LP_QPKGCFG | grep -w Status| sed 's/ //g' | sed 's/Status\=//g'`)

## Generate App Info
rm -f $LPP/appinfo
for (( i=1; i<=$lp_AppNumber; i=i+1 ));
do 
echo ${lp_AppName[i]} ${lp_App_Author[i]} ${lp_App_Enable[i]} ${lp_AppVersion[i]} ${lp_APP_Status[i]} ${lp_App_Date[i]}     | tee -a $LPP/appinfo 1>/dev/null 2>&1

done 


##generate df without mounted snapshots 
cat $Path/Q*.html | grep "\=\ \[\ VOLUME\ IN" -A 30 | grep "%"| grep -v snapshot > $LPP/df 
##generate datavolume
cat $Path/Q*.html | grep "\=\ \[\ VOLUME\ IN" -A 30 | grep "%" |grep "DATA"| grep -v "DATA\/" | tr -s " " >$LPP/davo
sed -e 's/\/dev\/mapper\/cachedev[0-9]//g' $LPP/davo |sed -e 's/\/dev\/md[0-9]//g' |tr -s " " >$LPP/davo2



progress="2/5 loading volume information"
progress_bar




## generate qcli_storage -d

cat $Path/Q*.html | sed -n '/sbin\/qcli/,$p' | sed -n '/\[/q;p' | grep -v "qcli_\|VOL" > $LPP/qclistoraged
# cat $Path/Q*.html | grep "qcli_storage\ -d" -A 20 | grep -e "NAS_HOST" -e "Enclosure" > $LPP/qclistoraged
## Disk informaiton
cat $Path/etc/enclosure_0.conf | grep model | sed -e 's/model\ \=\ //g' > $LPP/disks
## generate disk variables
lp_DiskNumber=$(cat $Path/etc/enclosure_0.conf | grep -i model |wc -l)
#lp_DiskName=(echo `cat $Path/etc/enclosure_0.conf | grep model | sed -e 's/model\ \=\ //g'`)
lp_PortID=(echo `cat $Path/etc/enclosure_0.conf | grep port_id |sed 's/ //g' | sed 's/port_id\=//g'`)
lp_DiskName=(echo `cat $Path/etc/enclosure_0.conf | grep model |sed 's/ //g' | sed 's/model\=//g'`)
lp_SysName=(echo `cat $Path/etc/enclosure_0.conf | grep pd_sys_name |sed 's/ //g' | sed 's/pd\_sys\_name\=//g'`)
lp_ReadSpeed=(echo `cat $Path/etc/enclosure_0.conf | grep read_speed |sed 's/ //g' | sed 's/read\_speed\=//g'`)



progress="3/5 loading RAID inoformation"
progress_bar


## generate md_checker
#cat $Path/Q*.html | grep "\=\ \[\ MD\ CH" -A 100 | grep -e "NAS_HOST" -e "Enclosure" -e Status -e Creation -e Version -e Chunk -e Name -e  Devi -e Leve -e UUID  -e Missing -e active -e "RAID\ m" -e ================= -C 1 > $LPP/.md_checker_tmp



cat $Path/Q*.html |sed -n '/Welcome\ t/,$p' |sed -n '/IFCONFIG/q;p'| grep -v "</"> $LPP/.md_checker_tmp
head -n  $((`cat $LPP/.md_checker_tmp |wc -l`/2)) $LPP/.md_checker_tmp > $LPP/md_checker

## generate mdadm 
cat $Path/Q*.html |  grep "ENCLOSURE_0 PORT" -A 28 > $LPP/.mdadmE_tmp
#mdadm_line=$(grep -n "===" $LPP/.mdadmE_tmp | cut -d : -f 1 | tr "\n" " "|awk '{print $2}')-3

## generate mdadm -E
     for (( i=1; i<=$lp_DiskNumber; i=i+1 ));
do 
 cat  $LPP/.mdadmE_tmp | grep ${lp_SysName[i]} -A 28 |sed -n '/\=\=\=\=/q;p' > $LPP/mdadmE_${lp_PortID[i]}
  if grep -q "No md superblock detected" $LPP/mdadmE_${lp_PortID[i]}; then

            echo "No md superblock detected on ${lp_SysName[i]}" > $LPP/mdadmE_${lp_PortID[i]}
        else
           :
        fi
done



progress="4/5 loading File system information "
progress_bar



## Generate RAID temp config
#cat $Path/etc/config/raid.conf | grep "\[RA" -A 24 |sed 's/ //g' |tr '\n' ' '|sed 's/\_//g'|tr '\[' '\n'| sed 's/\]//g' | sed '1d' >$LPP/.raid.tmp


cat $Path/etc/config/raid.conf | grep "\[RA" -A 24 \
| grep -e "\[RA" -e uuid  -e id -e partNo -e aggreMember -e readOnly -e legacy -e version2 -e overProvisioning -e devceName -e raidLevel -e internal -e mdBitmap -e chunkSize -e readAhead -e stripeCacheSize -e speedLimitMax -e speedLimitMin -e data -e dataBitmap -e srubStatus -e eventSkipped -e eventCompleted -e degradedCnt \
|sed 's/ //g' |sed 's/\_//g' |tr '\n' ' '|tr '\[' '\n'| sed 's/\]//g' | sed '1d' |sort -k1 -V >$LPP/.raid.tmp



## generate memory info
cat $Path/Q*.html | sed -n '/\#\ dmi/,$p' | sed -n '/\<a\ name\=\"\BLOCK/q;p' > $LPP/memoryinfo




## Volume information
cat $Path/etc/config/qlvm.conf | grep "\[L" -A 16 \
| grep -e "\[LV" -e lvId -e poolId -e flag -e threshold -e lvName -e uuid -e completeFsResize -e overThreshold -e lvSize -e memberBitmap -e member_0 -e volName \
|sed 's/ //g' |sed 's/\_//g' |tr '\n' ' '|tr '\[' '\n'| sed 's/\]//g' | sed '1d' |sort -k1 -V >$LPP/qlvm

awk '{print $1"\_"$2,$1"\_"$3,$1"\_"$4,$1"\_"$5,$1"\_"$6,$1"\_"$7,$1"\_"$8,$1"\_"$9,$1"\_"$10,$1"\_"$11,$1"\_"$12,$1"\_"$13}' $LPP/qlvm | sed 's/ /\n/g' |sed '/LV[1-9][1-9]\_$/d' |sed '/LV[1-9]\_$/d'> $LPP/qlvm_parameter
chmod 755 $LPP/qlvm_parameter
source $LPP/qlvm_parameter

# parsing volume.conf
cat $Path/etc/volume.conf | grep "\[V" -A 27 \
| grep -e "\[VO" -e volID  -e volName -e raidID -e raidName -e ssdCache -e unclean -e filesystem -e mappingName -e readOnly -e writeCache -e invisible -e raidLevel -e status -e time -e baseId -e baseName -e inodeRatio -e volType \
|sed 's/ //g' |sed 's/\_//g' |tr '\n' ' '|tr '\[' '\n'| sed 's/\]//g' | sed '1d' |sort -k1 -V >$LPP/qvolume

# generate volume info
awk '{print $1"\_"$2,$1"\_"$3,$1"\_"$4,$1"\_"$5,$1"\_"$6,$1"\_"$7,$1"\_"$8,$1"\_"$9,$1"\_"$10,$1"\_"$11,$1"\_"$12,$1"\_"$13,$1"\_"$14,$1"\_"$15,$1"\_"$16,$1"\_"$17}' $LPP/qvolume | sed 's/ /\n/g' |sed '/VOL[1-9][1-9]\_$/d' |sed '/VOL[1-9]\_$/d'> $LPP/qvolume_parameter
chmod 755 $LPP/qvolume_parameter
source $LPP/qvolume_parameter

## generate file system block
cat $Path/Q*.html | sed -n '/sbin\/tune2fs/,$p' |  sed -n '/\<a\ name\=\"\QCLI\_/q;p' > $LPP/filesystem


#generate volume number
#VolNumber=$(cat $LPP/filesystem | grep cachedev | wc -l)
#VolName=(echo `cat $LPP/filesystem| grep -oE "cachedev[1-9]{1,2}" |sed 's/cachedev//'`)

#echo $VolNumber
#echo ${VolName[2]}

 

## Generate Shared folder temp config
cat $Path/etc/config/smb.conf | grep "\[" -A 23 |sed 's/ //g' |tr '\n' ' '|tr '\[' '\n'| sed 's/\]//g' | grep -v global | grep -v printers | grep -v "\=Home">$LPP/.shared_folders.tmp


## Generate LVS info
cat $Path/Q*.html| grep lvs -A  50 | grep -e "VG" -e "vg1" -e "vg2" -e "vg3" -e "vg288" -e "vg289" | grep -v "VG Name" >$LPP/lvs
cat $Path/logparser/lvs | grep -Eo "^\ \ lv[0-9]{1,3}\ "  > $LPP/lvsname


cat $Path/Q*.html | sed -n '/\-\-map\<\/\b\>/,$p' |sed -n '/\[/q;p' > $LPP/lvdisplay

#cat $LPP/lvdisplay| grep "tp[0-9]_tmeta" -B 5 -A 6 | grep -e "LV Name" -e "Allocated pool" | sed 's/\ \ Allocated\ pool\ data/allocated/g' | sed 's/\ \ Allocated\ pool\ chunks/chunk/g'| tr -d ".,%,\r"|sed 's/\ \ LV\ Name/tpname/g' | tr -s " "| tr " " "=" > $LPP/tp_remainsize
#chmod 755 $LPP/tp_remainsize
#source $LPP/tp_remainsize

## Generate PVS info
cat $Path/Q*.html| grep pvs -A 10 | grep -i vg > $LPP/pvs




## Generate SSD info
cat $Path/etc/config/ssdcache.conf | grep "\[SSD" -A 10 \
| grep -e "\[SSD" -e ssdCacheId -e ssdCacheName -e qdmId -e lvId -e groupId -e uuid -e flag -e enabled -e reserved -e sysCache \
|sed 's/ //g' |sed 's/\_//g' |tr '\n' ' '|tr '\[' '\n'| sed 's/\]//g'| sed '1d' |sort -k1 -V >$LPP/ssdcache_cache

cat $Path/etc/config/ssdcache.conf | grep "\[CG" -A 12 \
| grep -e "\[CG" -e groupId -e groupName -e lvId -e mode -e replaceAlgorithm -e bypass_threshold -e flag -e enabled -e member_0 -e memberBitmap -e member_1 -e op_ratio \
|sed 's/ //g' |sed 's/\_//g' |tr '\n' ' '|tr '\[' '\n'| sed 's/\]//g'| sed '1d' |sort -k1 -V >$LPP/ssdcache_cg

awk '{print $1"\_"$2,$1"\_"$3,$1"\_"$4,$1"\_"$5,$1"\_"$6,$1"\_"$7,$1"\_"$8,$1"\_"$9,$1"\_"$10,$1"\_"$11,$1"\_"$12,$1"\_"$13}' $LPP/ssdcache_cache \
| sed 's/ /\n/g' | sort -u| sed '/SSDCache[0-9]\_$/d' | sed '/SSDCache[0-9][0-9]\_$/d' | sed '/SSDCache[0-9][0-9][0-9]\_$/d'> $LPP/ssdcache_cache_parameter
chmod 755 $LPP/ssdcache_cache_parameter
source $LPP/ssdcache_cache_parameter

awk '{print $1"\_"$2,$1"\_"$3,$1"\_"$4,$1"\_"$5,$1"\_"$6,$1"\_"$7,$1"\_"$8,$1"\_"$9,$1"\_"$10,$1"\_"$11,$1"\_"$12,$1"\_"$13}' $LPP/ssdcache_cg | sed 's/ /\n/g' | sed '/CG[0-9]\_$/d' > $LPP/ssdcache_cg_parameter
chmod 755 $LPP/ssdcache_cg_parameter
source $LPP/ssdcache_cg_parameter


## Generate Network log
cat $Path/Q*.html| sed -n '/sbin\/ifconfig/,$p' | sed -n '/IRQ\ INFO/q;p'| sed -n '/\=\ \[\ D/q;p' > $LPP/network



## myqnapcloudurl
myQNAPCloudUrl=$lp_DEVICENAME'.myqnapcloud.com'



## System log
cat $Path/Q*.html|sed -n '/\-qv/,$p' | sed -n '/Done/q;p' > $LPP/systemlog

#cat $Path/Q*.html | grep ',20[0-9][0-9]-' > $LPP/systemlog

## Generate Access log
cat $Path/Q*.html| sed -n '/\-\-gpdr/,$p' | sed -n '/Done/q;p'| sed -n '/\=\ \[\ D/q;p' > $LPP/accesslog

#cat $LPP/accesslog | awk -F "," '{print $1,$2,$3,$4,$5}'
# cat $LPP/accesslog | awk -F, '{print $3" "$5" "$6" "$13" "$14" "}'

## Kernel log
cat $Path/Q*.html | grep -e '<[0-9]>' -e "\[Diagnostic" >$LPP/kernellog



##if migrated 
modelhistory=(echo `cat $LPP/kernellog |grep -e "boot finished" -e Diag | sed -n 's/^.*\=\=/\=\=/p'| awk '{print $4}'  | sort -u `)


## generate ps
cat $Path/Q*.html| grep "[0-9]\ admin\ \ " > $LPP/process

## gernate special variables
QTSv_shortform=(`echo $lp_Firmware |cut -d "_" -f 1`)  ## shot QTS version, for example 5.0.1_0423 > 5.0.1

## generate zfsgetall
#cat $Path/Q*.html| grep -i "zfs get all" -A 1500 | grep zpool1 | grep -v "202*-" > $LPP/zfsgetall

cat $Path/Q*.html| sed -n '/zfs\ get\ all\ \]\ /,$p' | sed -n '/history\ \-i/q;p' | grep -v "history\_" > $LPP/zfsgetall
#cat $LPP/zfsgetall | grep -w "used\|usedbydataset\|usedbysnapshots\|refreservation\|qnap:zfs_volume_name\|refquota\|snap_refreservation\|qnap:pool_flag\|overwrite_reservation" | \
#grep -v "@snapshot\|@:init\|RecentlySnapshot\|zpool[1-9]\ \|zpool256\ \|53[0-9]\/" | sed 's/zpool[1-9]\///' | \
#sed 's/\:/_/' |sed 's/zfs//' | sort -nk1 | tr -s " " | awk '{print "ZFS"$1"_"$2"="$3}' > $LPP/qzfs_parameter


cat $LPP/zfsgetall | grep -w "used\|usedbydataset\|usedbysnapshots\|refreservation\|qnap:zfs_volume_name\|refquota\|snap_refreservation\|qnap:pool_flag\|overwrite_reservation" | \
grep -v "@snapshot\|@:init\|RecentlySnapshot\|zpool[1-9]\ \|zpool256\ \|53[0-9]\/" | sed 's/zpool[1-9]\///' | sed 's/\:/_/' |sed 's/zfs//' | sort -nk1 > $LPP/zfs_info
cat $LPP/zfs_info | tr -s " " | awk '{print "ZFS"$1"_"$2"="$3}' > $LPP/qzfs_parameter

}



#TinySys(){
# awk -F "," '{print $3,$4,$8 }'
#}

TinySys(){
awk -F\, '{ if ($2==1){print "\033[33m"w"\033[33m" $3,$4,$8   } else if ($2==2){print "\033[35m"e"\033[35m" $3,$4,$8} else if ($2==0){print "\033[39"n"\033[39m" $3,$4,$8}     }'; echo "\033[0m"
}

ColorSys(){
awk -F\, '{ if ($2==1){print "\033[33m"w"\033[33m" $0   } else if ($2==2){print "\033[35m"e"\033[35m" $0} else if ($2==0){print "\033[39"n"\033[39m" $0}     }'; echo "\033[0m"
}


Basic_information(){
 #cat $Path/Q*.html | grep -e "Serial Number:\ Q" -e "MAC:" -e "Firmware:" -e "Model:" | grep -v eth | grep -v PHY
 #cat $Path/etc/config/uLinux.conf | grep -e "Web Access Port" -e "SSH Enable" -e "SSH Port" -e "TELNET Enable" -e "HomeLink" -e "ACL Enable" -e "Init ACL"

echo Serial number: $lp_SerialNumber
echo Date: $lp_Date
echo Model: $lp_Model
echo Firmware: $lp_Firmware
echo Server Name: $lp_ServerName
printf "\n"
echo enabling SSH: $lp_SSHEnable using port $lp_SSHPort
echo enabling Telnet: $lp_TELNETEnable using port $lp_TELNETPort
echo Web Management Port: $lp_WebAccessPort
echo enabling 2 step verification: $lp_2stepverification
echo enabling connection log: $lp_WriteConnectionLog
printf "\n"
echo enabling home folder: $lp_HomeLink
#echo enabling ACL: 
printf "\n"
echo enabling Wake on LAN: $lp_WakeOnLan
echo enabling Disk Standby mode: $lp_DiskStandByTimeoutEnable
echo enabling Buzzer: $lp_BuzzerWarningEnable

echo enabling NTP server: $lp_EnableNTPServer
echo last time check firmware live update: $lp_LatestCheckLiveUpdate
echo last time firmware live update: $lp_LatestLiveUpdate

printf "\n"
echo SSL info
cat $LPP/stunnel


#cat $Path/etc/config/uLinux.conf | grep "Stunnel" -A 2

#cat $Path/Q*.html | grep -e "dmidecode\ -s\ bios-version" -e "hal_app\ --get_ec_version" -A 2 | grep -v \/a | grep -e Q -e S |sed  's/\n/ /g'


 


}



Volume_information(){


    Volume_questions
    Volume_input

}


Volume_questions(){

#        
        echo question:
        echo 1. df
        echo 2. qlvm.conf info
        echo 3. file system
        echo 4. Volume.conf ifno
        echo 5. Advanced volume info
        printf "\n"
        printf "\n"
        echo q. Leave
        printf "\n"
        echo Input Number:

        read VIANS
}

Volume_input(){

    case $VIANS in
        1)
        clear 

      #cat $Path/Q*.html | grep "\=\ \[\ VOLUME\ IN" -A 30 | grep "%" > $LPP/df    
cat $LPP/df | grep -v DATA
printf "\n"
printf "\n"

cat $Path/Q*.html | grep "<b>mount" -A 40 | grep -w on | grep -v tmpfs

#echo the following volume is full
#cat $Path/Q*.html | grep "\=\ \[\ VOLUME\ IN" -A 30 | grep "100%" 

printf "\n"
   
        printf "\n"
        #rm $Path/davo

        #cat $Path/Q*.html | grep "\=\ \[\ VOLUME\ IN" -A 30 | grep "%" |grep "DATA"| grep -v "DATA\/" | tr -s " " >$LPP/davo

        # sed -e 's/\/dev\/md[0-9]//g' $Path/davo 
        #sed -e 's/\/dev\/mapper\/cachedev[0-9]//g' $LPP/davo |sed -e 's/\/dev\/md[0-9]//g' |tr -s " " >$LPP/davo2
        ##cat $Path/davo2

        # awk '{print $1/1073741824"T",$2/1073741824"T",$3/1073741824"T",$5}' $Path/davo2
        #awk '{print $1/1073741824"T"}' $Path/davo
        #awk '{print $1/1073741824"T",$2/1073741824"T",$3/1073741824"T",$4,$5,$6}' $Path/davo

        awk '{printf "Volume: %s\n                                 Total = %.2fT Used = %.2fT Available = %.2fT\n\n",$5,$1/1073741824,$2/1073741824,$3/1073741824}' $LPP/davo2
        #cat $LPP/davo2 |sed 's/ //' |awk '{printf "%-30s  %-20.2fT %-20.2fT %-20.2fT %-20s \n",$5,$1/1073741824"T",$2/1073741824,$3/1073741824,$4}'
        # cat $LPP/davo2 |sed 's/ //' |awk '{printf "%s\n",$5}'
        printf "\n"


        press_enter 
        Volume_information

        ;;
        2)
        clear

        # cat $Path/etc/config/qlvm.conf| grep -e lvName -e volName
#awk '{printf "%-6s  %-25s %-10s %-10s %-15s %-30s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n",$1,$8,$2,$3,$4,$5,$6,$7,$12,$13,$14,$15,$16}' $LPP/qlvm

cat $LPP/qlvm_parameter
printf "\n"
printf "\n"

    

        press_enter 
        Volume_information

        
        ;;

        3)
        clear

        cat  $LPP/filesystem


    

        press_enter 
        Volume_information

        
        ;;

             4)
        clear

        # cat $Path/etc/config/qlvm.conf| grep -e lvName -e volName
#awk '{printf "%-6s  %-25s %-10s %-10s %-15s %-30s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n",$1,$8,$2,$3,$4,$5,$6,$7,$12,$13,$14,$15,$16}' $LPP/qlvm
#awk '{print $1"\_"$2,$1"\_"$3,$1"\_"$4,$1"\_"$5,$1"\_"$6,$1"\_"$7,$1"\_"$8,$1"\_"$9,$1"\_"$10,$1"\_"$11,$1"\_"$12,$1"\_"$13,$1"\_"$14,$1"\_"$15}' $LPP/qvolume
cat $LPP/qvolume_parameter
printf "\n"
printf "\n"

    

        press_enter 
        Volume_information

        
        ;;


        5)



clear


lp_VolumeNumber=$(cat $LPP/qvolume_parameter | grep -i mappingName |wc -l)

for (( i=1; i<=$lp_VolumeNumber; i=i+1 ));
do 

VolumeName="VOL${i}_volName"
VolumeMappingname="VOL${i}_mappingName"
VolumeSSD="VOL${i}_ssdCache"
VolumeNotclean="VOL${i}_unclean"
Volumeinode="VOL${i}_inodeRatio"
VolumeStatus="VOL${i}_status"
VolumeRaid="VOL${i}_raidName"
VolumeRaidLevel="VOL${i}_raidLevel"
VolumeReadOnly="VOL${i}_readOnly"
VolumeType="VOL${i}_volType"

VolumeBaseID="VOL${i}_baseId"
#VolumeSSDEnable="CG${!VolumeBaseID}_enabled"
#VolumeSSDMode="CG${!VolumeBaseID}_mode"

VolumeThreshod="LV${!VolumeBaseID}_threshold"
VolumelvName="LV${!VolumeBaseID}_lvName"

VolumeSSDNumber="SSDCache${!VolumeBaseID}_groupId"
VolumeSSDEnable="CG${!VolumeSSDNumber}_enabled"
VolumeSSDMode="CG${!VolumeSSDNumber}_mode"


echo Volume $i/$lp_VolumeNumber
echo "Volume Name: ${!VolumeName}"
# echo "Volume Type: ${!VolumeType}"
echo "Volume Threshold: ${!VolumeThreshod}%"
cat $Path/etc/config/lvm/backup/* | grep -w lv$i -A 13 | grep type| cut -d "=" -f2|tr "\"" "\ " | awk '{if ($1=="thick") {print "Volume Type: Thick volume"} else if ($1=="thin") {print "Volume Type: Thin volume"}else if ($1=="striped") {print "Volume Type: Static volume"} }'

case ${!VolumeStatus} in
0)

printf "Volume status: Normal\n"
;;
72)

printf "Volume status: \e[1;31mRead/Delete\e[0m\n"
;;


*)

printf "Volume status: Unknown(${!VolumeStatus})\n"

esac

# volume type
# echo `cat $LPP/lvdisplay| grep -w lv${!VolumeBaseID} -A 21 | head -n 21 | grep Type`


printf "\n"

echo "Volume Read Only: ${!VolumeReadOnly}"
echo "File system not clean: ${!VolumeNotclean}" 
echo "Volume inode: ${!Volumeinode}"
printf "\n"

echo "Volume Path: ${!VolumeMappingname}"
echo "Volume LV Path: ${!VolumelvName}"
echo "Volume on RAID: ${!VolumeRaid},RAID(${!VolumeRaidLevel})"

printf "\n"
echo "Volume SSD applied: ${!VolumeSSD}"

case ${!VolumeSSD} in 

no)
:
;;
yes)

###########
echo "Volume SSD Enable: ${!VolumeSSDEnable}"




case ${!VolumeSSDMode} in 
    1)
echo "Volume SSD Mode: read-write"
;;
2)
echo "Volume SSD Enable: read-only"
;;

4)echo "Volume SSD Enable: write-only"
;;

esac
###########

;;
esac







printf "\n"
grep "l\ ${!VolumeMappingname}<" -A 40 $LPP/filesystem | grep -e "Free inodes" -e "state" -e "Inodes per group" -e "Filesystem created" -e "Last mount time" -e "Last checked" 
printf "\n"
echo Press enter to process:
read anything
clear
done






        Volume_information


        ;;



        q)
        ;;


         *)
        echo "Not supported"
        
        ;;
esac


}



RAID_information(){


RAID_questions
RAID_input


}


RAID_questions(){

        echo "###########"
        echo 1. MD_Checker
        echo 2. mdstat
        echo 3. RAID.conf info
        echo 4. mdadm \-E
        echo 5. kernel log message regarding ATA DRBD MD DEVICE-MAPPER CACHE
        echo 6. System log message regarding RAID
        printf "\n"
        printf "\n"
        echo q. Leave
        printf "\n"
        echo Input Number:

        read RAANS


}



RAID_input(){


	case $RAANS in
		1)
		clear 

		echo MD_Checker
   	    cat $LPP/md_checker
        cat $Path/Q*.html | grep "Bad Block Log"


		press_enter 
		RAID_information

		;;
		2)
        clear

		echo mdstat
		cat $Path/proc/mdstat


		press_enter 
		RAID_information
		;;

        3)
        clear

        #awk '{printf "%-5s  %s_%-5s %s_%-8s %-10s %-10s %-10s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n",$1,$1,$3,$1,$4,$6,$7,$8,$10,$11,$12,$13,$14,$20,$21,$22}' $LPP/.raid.tmp
        #awk '{print $1"\_"$8,$1"\_"$2,$1"\_"$3,$1"\_"$4,$1"\_"$5,$1"\_"$6,$1"\_"$7}' $LPP/.raid.tmp | sed 's/ /\n/g'
        awk '{print $1"\_"$2,$1"\_"$3,$1"\_"$4,$1"\_"$5,$1"\_"$6,$1"\_"$7,$1"\_"$8,$1"\_"$9,$1"\_"$10,$1"\_"$11,$1"\_"$12,$1"\_"$13,$1"\_"$14,$1"\_"$15,$1"\_"$16,$1"\_"$17,$1"\_"$18,$1"\_"$19,$1"\_"$20}' $LPP/.raid.tmp | sed 's/ /\n/g' |sed '/RAID[1-9]\_$/d'

        press_enter 
        RAID_information
        ;;
        4)
        clear

        for (( i=1; i<=$lp_DiskNumber; i=i+1 ));
        do

        cat $LPP/md_checker | grep -e Name -e NAS_HOST -e Missing -e active | grep --color -E '${lp_SysName[i]}|$' # grep --color -E 'Port|$'
        echo "######"
        echo $i/$lp_DiskNumber, Port ID: ${lp_PortID[i]} 
        echo Disk model: ${lp_DiskName[i]}
        echo System Name: ${lp_SysName[i]}
        echo "######"
        cat  $LPP/mdadmE_${lp_PortID[i]} | grep --color -E 'spare|$'
        press_enter 
        done

        


        press_enter 
        RAID_information
        ;;


        5)
        clear

        echo md
        cat $LPP/kernellog | grep -i "device-mapper\|md\|drbd\|ext\|cache\|ata"

        press_enter 
        RAID_information
        ;;


        6)
        clear

        echo RAID
        cat $LPP/systemlog | grep "RAID" | TinySys

        press_enter 
        RAID_information
        ;;







		q)

		;;


		 *)
        echo "Not supported"
        
        ;;
esac



}




APP_informaiton(){
APP_question
APP_input

 # cat $Path/etc/config/qpkg.conf | grep -e '\[' -e Enable -e Version -e Author -e Install_Path

# rm -f $LPP/appinfo
#printf "%-25s  %-20s %-10s %-10s %-10s %-10s %-10s \n" "App name" "Author" "Enable" "Version" "Status" "Date" 
#cat $LPP/appinfo | sort -t " " -nk1| awk '{printf "%-25s  %-20s %-10s %-10s %-10s %-10s \n",$1,$2,$3,$4,$5,$6}'
#for (( i=1; i<=$lp_AppNumber; i=i+1 ));
#do 
#echo ${lp_AppName[i]} ${lp_App_Author[i]} ${lp_App_Enable[i]} ${lp_AppVersion[i]} ${lp_APP_Status[i]} ${lp_App_Date[i]}     | tee -a $LPP/appinfo 1>/dev/null 2>&1

#echo ${lp_APP_Status[i]} ${lp_App_Date[i]} ${lp_App_Author[i]} ${lp_App_Enable[i]} ${lp_AppVersion[i]} ${lp_AppName[i]} | tee -a $LPP/appinfo 1>/dev/null 2>&1
#done 


# cat $LPP/appinfo | sed 's/ //g' |sed 's/,/ /g' | awk '{printf "%-25s  %-20s %-10s %-10s %-10s %-10s %-10s \n",$7,$3,$4,$5,$6,$1,$2}'
# cat $LPP/appinfo | sort -t " " -nk1| awk '{printf "%-25s  %-20s %-10s %-10s %-10s %-10s \n",$1,$2,$3,$4,$5,$6}'

#echo $lp_platform
#echo $QTSv_shortform
#echo https://download.qnap.com/Liveupdate/QTS$QTSv_shortform/qpkgcenter_eng.xml
#curl https://download.qnap.com/Liveupdate/QTS$QTSv_shortform/qpkgcenter_eng.xml | grep zip | sort -u | grep -e $lp_platform -e master | cut -c 48- | sed 's/\<\/location\>//g' > $LPP/latestappinfo #| grep -v HDV3 |sed -e 's/<[^>]*>//g' 
#curl https://download.qnap.com/Liveupdate/QTS$QTSB/qpkgcenter_eng.xml | grep zip | sort -u #| grep -e $lp_platform -e master| grep -v HDV3 |sed -e 's/<[^>]*>//g' 


#cat $LPP/appinfo | sort -t " " -nk1| awk '{print $1,grep $1 $LPP/latestappinfo}'
#printf "\n"
#cat $LPP/latestappinfo
}

APP_question(){

        echo question:
        echo 1. Installed APP
        echo 2. Latest APP can be installed
        # echo 3. ATA bus error/Media error/IO error
        printf "\n"
        printf "\n"
        echo q. Leave
        printf "\n"
        echo Input Number:

        read APANS

}

APP_input(){



    case $APANS in
        1)
        clear 

        printf "%-25s  %-20s %-10s %-10s %-10s %-10s %-10s \n" "App name" "Author" "Enable" "Version" "Status" "Date" 
        cat $LPP/appinfo | sort -t " " -nk1| awk '{printf "%-25s  %-20s %-10s %-10s %-10s %-10s \n",$1,$2,$3,$4,$5,$6}'

        press_enter 
        APP_informaiton

        ;;
        2)
        clear

        echo 2

        echo $lp_platform
        echo $QTSv_shortform
        echo https://download.qnap.com/Liveupdate/QTS$QTSv_shortform/qpkgcenter_eng.xml

        curl https://download.qnap.com/Liveupdate/QTS$QTSv_shortform/qpkgcenter_eng.xml | grep zip | sort -u | grep -e $lp_platform -e master | cut -c 48- | sed 's/\<\/location\>//g' # > $LPP/latestappinfo #| grep -v HDV3 |sed -e 's/<[^>]*>//g' 
        #curl https://download.qnap.com/Liveupdate/QTS$QTSB/qpkgcenter_eng.xml | grep zip | sort -u #| grep -e $lp_platform -e master| grep -v HDV3 |sed -e 's/<[^>]*>//g' 




        press_enter 
        APP_informaiton
        ;;
        q)
        ;;


         *)
        echo "Not supported"
        
        ;;
esac



}




Disk_information(){

    


Disk_question
Disk_input


}



Disk_question(){

#        
        echo question:
        echo 1. Qcli_storage
        echo 2. SMART_info
        echo 3. ATA bus error/Media error/IO error
        echo 4. Expansion cards or units
        printf "\n"
        printf "\n"
        echo q. Leave
        printf "\n"
        echo Input Number:

        read DSANS

}

Disk_input(){

    case $DSANS in
        1)
        clear 

        

     if [ $modeltype -eq 1 ]; then 
        echo This is a HAL model
        printf "\n"

         
        #cat $Path/Q*.html | grep "qcli_storage\ -d" -A 20 | grep -e "NAS_HOST" -e "Enclosure" > $LPP/qclistoraged
        cat $LPP/qclistoraged 
        ## cat $Path/Q*.html | grep "qcli_storage\ -d" -A 20 | grep -e "NAS_HOST" -e "Enclosure" | tr -s " "> $Path/disks
         
        #awk '{print " ",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17}' $Path/disks
        #awk '{print $NF}' $Path/disks
        printf "\n"
        # cat $Path/etc/enclosure_0.conf | grep model | sed -e 's/model\ \=\ //g' > $LPP/disks
        # cat $Path/etc/enclosure_0.conf | grep read_speed
       
        # cat $LPP/disks
        # disk_number=`cat $LPP/disks |wc -l`
        # echo $disk_number
        # printf "\n"

        # echo Disk Health
        # cat $Path/tmp/smart/smart_0_* | grep "0x0000"
        # echo Power-On Hours
        # cat $Path/tmp/smart/smart_0_* | grep "Power-On_Hours"
       #  echo Current_Pending_Sector
        # cat $Path/tmp/smart/smart_0_* | grep "Current_Pending_Sector" 

        #cat $Path/mnt/HDA_ROOT/.conf


     elif  [ $modeltype -eq 2 ]; then 
        echo This is a legacy model
        cat $Path/mnt/HDA_ROOT/.conf |grep serial_no
else
    echo I don\'t know
     fi







        press_enter 
        Disk_information

        ;;
        2)
        clear

          if [ $modeltype -eq 1 ]; then 
        echo This is a HAL model
        printf "\n"


for (( i=1; i<=$lp_DiskNumber; i=i+1 ));
do 
clear
echo "######"
echo Disk model: ${lp_DiskName[i]}
echo System Name: ${lp_SysName[i]}
echo Read Speed: ${lp_ReadSpeed[i]}
cat $Path/tmp/smart/smart_0_${lp_PortID[i]}.info | sed 's/ /\_/g' |sed 's/,/ /g' | grep Power-On_Hours |awk '{printf "Power on time: %dY:%dM:%dD RAW (%d) \n",$6/(24*30*12),$6%(24*30*12)/(24*30),$6%(30*24)/24,$6}'
# cat $Path/tmp/smart/smart_0_${lp_PortID[i]}.info | sed 's/ /\_/g' |sed 's/,/ /g' | awk '{print $2,"Current " $3,"Worst " $4,"Threshold " $5,"RAW " $6}' | grep -e Power_On -e Power-On -e Reallo -e Pending -e Unco -e Power_Cycle -e "^Temperature"
printf "%-30s  %-10s %-10s %-10s %-10s \n" "Attribute Name" "Current" "Worst" "Threshod" "RAW"
cat $Path/tmp/smart/smart_0_${lp_PortID[i]}.info | sed 's/ /\_/g' |sed 's/,/ /g' | awk '{printf "%-30s  %-10s %-10s %-10s %-10s \n",$2,$3,$4,$5,$6}' |more
printf "\n"
printf "\n"
#hours=29840;printf '%dY:%dM:%dD\n' $((hours/(24*30*12))) $((hours%(24*30*12)/(24*30))) $((hours%(30*24)/24))
done


     elif  [ $modeltype -eq 2 ]; then 
        echo This is a legacy model
        echo No SMART Info in diagnostic log
else
    echo I don\'t know
     fi
        


        press_enter 
        Disk_information
        ;;


            3)
        clear


            cat $LPP/kernellog |grep -e "ATA bus error" -e "media error" -e "I/O error" --color=auto

        press_enter
        Disk_information
        ;;

            4)
        clear


              cat $Path/Q*.html| grep "= \[ hal_app --se_enum " -A 50| grep QNAP | grep -v BOOT | grep -v USB 

        press_enter
        Disk_information
        ;;





        q)
        ;;


         *)
        echo "Not supported"
        
        ;;
esac

#echo this is a test funcion


}





Shared_folders_information(){

    echo Highest and lowest SMB version
    cat $Path/etc/config/smb.conf | grep -e protocol
    printf "\n"
    echo NAS is joined Domain or not and ABSE setting
	cat $Path/etc/config/smb.conf | grep -e "passdb" -e "server signing" -e "restrict a" -e "guest ok" -e "map to guest"
    echo Restrict Anonymous 0 means disabled
	printf "\n"
	#cat $Path/etc/config/smb.conf | grep -e '\[' -e Enable -e path | grep -v "\[g"
    #awk '{printf "%-6s  %-25s %-10s %-10s %-15s %-30s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n",$1,$8,$2,$3,$4,$5,$6,$7,$12,$13,$14,$15,$16}' $LPP/.shared_folders.tmp
    awk '{printf "%-20s  %-50s %-15s %-15s %-15s \n ",$1,$3,$9,$10,$14,$15}' $LPP/.shared_folders.tmp

}


Systemlog_information(){

Systemlog_questions
Systemlog_input

}


Systemlog_questions(){
	    clear
	   
        echo What information do you need from system log
        echo 1. Grep system log using keyowrd \(or 11\)
        echo 2. Firmware upgrade history
        echo 3. Abnormal Reboot history
        echo 4. Print all system log 
        echo 5. Print access log
        echo 6. Print system log in short form
        echo "   61. Power " 
        echo "   62. Storage & Snapshot " 
        echo "   63. Hybrid Backup sync " 
        echo "   64. Cache  "

        #echo 7. Show only warning system log
        #echo 8. Show only error system log
        printf "\n"
        echo or use the command: 
        echo cat $LPP\/systemlog \| grep your_keyword
        printf "\n"
        printf "\n"
        echo k. Kernellog Information
        echo q. Leave
        printf "\n"
        echo Input Number:

        read SLANS
}


Systemlog_input(){
	        case $SLANS in 


            1)
            clear

            echo Input your Keyword,the first keyword will be colored
            read grepfilter1 grepfilter2
            echo how many lines around keyord:
            read kround
            cat $LPP/systemlog | ColorSys | grep -i "$grepfilter2" | grep -i "$grepfilter1" --color=auto -$kround 
            #cat $LPP/systemlog | grep -E --color=auto '^|$grepfilter1|$grepfilter2'   # -$kround

  
            press_enter 
            Systemlog_information          
           
             ;;

              11)
            clear

            echo Input your Keyword,the first keyword will be colored
            read grepfilter1 grepfilter2
            echo how many lines around keyord:
            read kround
            cat $LPP/systemlog | TinySys | grep -i "$grepfilter2" | grep -i "$grepfilter1" --color=auto -$kround 
            #cat $LPP/systemlog | grep -E --color=auto '^|$grepfilter1|$grepfilter2'   # -$kround

  
            press_enter 
            Systemlog_information          
           
             ;;

        	2)
			clear


            cat $LPP/systemlog  |grep from | grep -i firmware


            press_enter 
            Systemlog_information      
            
             ;;
            3)
			clear


            cat $LPP/systemlog  | grep -i -e "not shut down" -e "not shutdown"

            press_enter 
            Systemlog_information       
          
              ;;



            4)
			clear

 # echo 0,0,END >> $LPP/systemlog | cat $LPP/systemlog | ColorSys 

                    cat $LPP/systemlog | ColorSys 


            press_enter 
            Systemlog_information      
            
             ;;

            
            5)
            clear


            cat $LPP/accesslog | ColorSys 


            press_enter 
            Systemlog_information      
            
             ;;


            6)
            clear


            cat $LPP/systemlog | TinySys


            press_enter 
            Systemlog_information      
            
             ;;



            61)
            clear

 # echo 0,0,END >> $LPP/systemlog | cat $LPP/systemlog | ColorSys 

                    cat $LPP/systemlog | grep "\[Power" |TinySys


            press_enter 
            Systemlog_information      
            
             ;;

             62)
            clear


            cat $LPP/systemlog  | grep "\[Sto" | TinySys


            press_enter 
            Systemlog_information      
            
             ;;

            63)
            clear


            cat $LPP/systemlog  | grep "\[Hyb" | TinySys


            press_enter 
            Systemlog_information      
            
             ;;


            64)
            clear


            cat $LPP/systemlog  | grep "\[Sto" | grep cache| TinySys


            press_enter 
            Systemlog_information      
            
             ;;




            7)
            clear


            cat $LPP/systemlog | awk -F\, '{ if ($2==1){print "\033[33m"w"\033[33m" $0   }    }' ; echo "\033[0m"


            press_enter 
            Systemlog_information      
            
             ;;

                         8)
            clear


            cat $LPP/systemlog |awk -F\, '{ if ($2==2){print "\033[35m"e"\033[35m" $0}     }' ; echo "\033[0m"


            press_enter 
            Systemlog_information      
            
             ;;


             k)

            kernellog_information
             ;;


            q)

			;;



                *)
    

         echo "Not supported"
         press_enter 
         Systemlog_information
        ;;
        esac
}

kernellog_information(){

	Kernellog_questions
	Kernellog_input


}




Kernellog_questions(){
        clear

        echo "##########"
        echo What information do you need from kernel log
        echo 1. Grep kernel log using keyowrd
        echo 2. print all
        echo 3. ATA bus error/Media error/IO error
        echo 4. Boot up history
        echo 5. dmesg before shut down
        echo 6. Call trace date
        echo 7. Cat PSTORE files
        printf "\n"
        echo or use the command: 
        echo cat $LPP\/kernellog \| grep your_keyword
        printf "\n"
        printf "\n"
        echo s. Systemlog Information
        echo q. Leave
        printf "\n"
        echo Input Number:

        read KLANS

}



Kernellog_input(){

 case $KLANS in 

        1)
        clear

            echo Input your Keyword,the first keyword will be colored
            read grepfilter1 grepfilter2
            echo how many lines around keyord:
            read kround
            cat $LPP/kernellog | grep -i "$grepfilter2" --color=auto | grep -i "$grepfilter1" --color=auto -$kround

             

        press_enter
        kernellog_information

        ;;


        	2)

		clear

            cat $LPP/kernellog

        press_enter
        kernellog_information
        ;;

        	3)
		clear


            cat $LPP/kernellog |grep -e "ATA bus error" -e "media error" -e "I/O error" --color=auto

        press_enter
        kernellog_information
        ;;

         4)
		clear

            cat $LPP/kernellog |grep -e "boot finished" -e Diag 

        press_enter
        kernellog_information
        ;;

 	

        5)
        clear

            cat $LPP/kernellog |grep -e mklog -e "\[Diagnostic" -B 10

        press_enter
        kernellog_information
        ;;


        6)
        clear

            cat $LPP/kernellog | grep -i "call trace:" | awk '{print $1}' | sort -u

        press_enter
        kernellog_information
        ;;



        7)
        clear

            cat $Path/sys/fs/pstore/con*

        press_enter
        kernellog_information
        ;;

        s)
        Systemlog_information

        ;;


        q)

		;;


                *)
        echo "Not supported"
        press_enter 
        kernellog_information
  
        ;;
        esac


}


Network_information()
{

Network_questions
Network_input

}




Network_questions()

{


        echo question:
        echo 1. ifconfig
        echo 2. route
        echo 3. outgoing log
        echo 4. gateway policy
        echo 5. devices used to connect to the NAS
        printf "\n"
        printf "\n"
        echo q. Leave
        printf "\n"
        echo Input Number:

        read NTANS


        
        

       

}

Network_input()
{



    case $NTANS in
        1)
        clear 

        echo ifconfig
        cat $LPP/network | sed -n '/G\ TA/q;p' | grep -v ifconfig | grep -v ROUTING


        press_enter 
        Network_information

        ;;
        2)
        clear

        echo Route 
        cat $LPP/network | grep "Kernel IP" -A 5


        press_enter 
       Network_information
        ;;


        3)
        clear

        echo outloging

        printf "\n"
        echo outgoing.log
        cat $Path/var/log/network/outgoing.log
        echo - 0: connecting success.
        echo  - 1: link-up failed.
        echo - 2: ARP request failed.
        echo - 3: DNS resolved failed.
        echo - 4: curl failed.

        



        press_enter 
        Network_information
        ;;



       4)
        clear

        echo gateway policy
        cat $Path/etc/config/nm.conf | grep gateway_policy
        printf "\n"
         echo gateway policy=1   fixed
         echo gateway policy=2   auto


        press_enter 
       Network_information
        ;;


5)
        clear

       cat $LPP/systemlog |  sed 's/ML,\ /ML\ /' | awk -F, '{print $6,$17}'| grep -v "\-\-\-" | sort -u 

cat $LPP/accesslog|  sed 's/ML,\ /ML\ /' |awk -F, '{print $6,$14}'|  grep -v "\-\-\-" | sort -u
       


        press_enter 
       Network_information
        ;;





        q)
        ;;


         *)
        echo "Not supported"
        
        ;;
esac






}








Cache_information(){

    #awk '{print $1"\_"$2,$1"\_"$3,$1"\_"$4,$1"\_"$5,$1"\_"$6,$1"\_"$7,$1"\_"$8,$1"\_"$9,$1"\_"$10,$1"\_"$11,$1"\_"$12,$1"\_"$13}' $LPP/ssdcache_cache | sed 's/ /\n/g' | sort -u| sed '/SSDCache[1-9]\_$/d' > $LPP/ssdcache_cache_paramter
cat $LPP/ssdcache_cache_parameter


#awk '{print $1"\_"$2,$1"\_"$3,$1"\_"$4,$1"\_"$5,$1"\_"$6,$1"\_"$7,$1"\_"$8,$1"\_"$9,$1"\_"$10,$1"\_"$11,$1"\_"$12,$1"\_"$13}' $LPP/ssdcache_cg | sed 's/ /\n/g' | sed '/CG[0-9]\_$/d' > $LPP/ssdcache_cg_paramter
cat $LPP/ssdcache_cg_parameter



	#cat $Path/etc/config/ssdcache.conf | grep -e "\[" -e mode -e enabled
	##sed 's/ //g' $Path/etc/config/ssdcache.conf > $Path/ssdcache
	##source $Path/ssdcache
	##echo $mode

	 printf "\n"
	  printf "\n"
	echo "Mode explanation:" 
	echo "read-write 1"
	echo "read-only 2"
	echo "write-only 4"
 
}
myQNAPcloud_information(){



myQNAPcloud_question
myQNAPcloud_input


}


myQNAPcloud_question(){

 if [ -z "$lp_QID" ]; then
            
            echo No QID
        else
       

echo QID: $lp_QID
echo Device name: $lp_DEVICENAME
echo Access Control: $lp_DEVICE_ACCESS_CONTROL_MODE
echo "#####"
grep DDNS -A 1 $Path/etc/config/qid.conf
echo "#####"
echo URL: $myQNAPCloudUrl
echo note: Install nmap using brew
 printf "\n"
  printf "\n"
#        
        echo question:
        echo 1. nmap $myQNAPCloudUrl -v
        echo 2. WAN IP updaetd by DDNS
        echo 3. nmap with configured port
        echo 4. curl -I with configured port
        echo 5. ping $myQNAPCloudUrl
        printf "\n"
        printf "\n"
        echo q. Leave
        printf "\n"
        echo Input Number:

        read MQANS
fi        
}

myQNAPcloud_input(){
    case $MQANS in
        1)
        clear 

        echo nmap $myQNAPCloudUrl 
        nmap $myQNAPCloudUrl -v


        press_enter 
        myQNAPcloud_information

        ;;
        2)
        clear

       
        cat $LPP/systemlog| grep "WAN IP"
        #cat $LPP/systemlog| grep "WAN IP" | sed 's/\[/\ /g' |sed 's/\]/\ /g'|sed 's/\"/\ /g' | cut -f8 -d","|grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| sort -u
        


        press_enter 
        myQNAPcloud_information
        ;;



        3)
        clear
 
       
        nmap $myQNAPCloudUrl -p T:$lp_SSHPort,$lp_TELNETPort,$lp_WebAccessPort
        


        press_enter 
        myQNAPcloud_information
        ;;



        4)
        clear

        echo curl -I -m 5 http://$myQNAPCloudUrl:$lp_WebAccessPort
        curl -I -m 5 http://$myQNAPCloudUrl:$lp_WebAccessPort
        


        press_enter 
        myQNAPcloud_information
        ;;

  5)
        clear

        echo ping http://$myQNAPCloudUrl:$lp_WebAccessPort
        ping $myQNAPCloudUrl
        


        press_enter 
        myQNAPcloud_information
        ;;

        q)
        ;;


         *)
        echo "Not supported"
        
        ;;
esac




}



Security_information(){

echo Model: $lp_Model
echo Firmware: $lp_Firmware
echo Server Name: $lp_ServerName
printf "\n"
echo enabling SSH: $lp_SSHEnable using port $lp_SSHPort
echo enabling Telnet: $lp_TELNETEnable using port $lp_TELNETPort
echo Web Management Port: $lp_WebAccessPort
echo enabling 2 step verification: $lp_2stepverification
echo enabling connection log: $lp_WriteConnectionLog
printf "\n"

echo enabling NTP server: $lp_EnableNTPServer
echo last time check firmware live update: $lp_LatestCheckLiveUpdate
echo last time firmware live update: $lp_LatestLiveUpdate

cat $Path/etc/config/qpkg.conf | grep -e '\[qufire' -A 24 | grep -e '\[' -e Enable

}

Memory_information(){

   cat $LPP/kernellog |grep -e "Memory:" | cut -d "(" -f1 | sort -u
   cat $Path/proc/meminfo | grep MemTotal    
   cat $LPP/memoryinfo | grep -e "Model:"
   cat $LPP/memoryinfo | grep -e "Manufacturer:" -e "\tType:" -e "\tSpeed" -e "\tSize" -e "Memory Device" | grep -v DIMM # grep tab \t


}


Process_information(){

	


    Process_question
    Process_input
	

}


Process_question(){

#        
        echo question:
        echo 1. Check if SMBD/AFPD/NFSD/Qsync is running
        echo 2. List all processes
        echo 3. list process using large amount of memory
        printf "\n"
        printf "\n"
        echo q. Leave
        printf "\n"
        echo Input Number:

        read PSANS

}
Process_input(){

    case $PSANS in
        1)
        clear 

        echo test1
        cat $LPP/process| grep -e smbd -e afpd -e nfsd -e qsyncsrv.fcgi -e upnpd | grep admin


        press_enter 
        Process_information

        ;;
        2)
        clear

        echo test2
        cat $LPP/process 


        press_enter 
        Process_information
        ;;


        3)
        clear

        echo test2
        cat $LPP/process | grep "M\ " |sort -k4 



        press_enter 
        Process_information
        ;;










        q)
        ;;


         *)
        echo "Not supported"
        
        ;;
esac

#echo this is a test funcion


}




RansomwareCheck_questions(){

	   

        echo What information do you need 
        echo 1. Print Firmware history in kernel log for QTS 4.4 or later
        echo 2. Print Firmware upgrade history in system log
        echo 3. Print Malware Remover update history
        echo 4. Print Malware Remover scan history
        echo 5. Print Photo Station update history [QSA-22-24]
        read RCANS


}

RansomwareCheck_information_input(){


	case $RCANS in 
        	1)
            cat $LPP/kernellog |grep -e "boot finished" -e Diag

        press_enter
        ;;

        	2)
            cat $LPP/systemlog | grep from | grep -i firmware | grep -E '\ [4-5].[0-5].[0-5].'

        press_enter
        ;;

         3)
            cat $LPP/systemlog | grep "Malware Remover" | grep -e "over from" 

        press_enter
        ;;

 		4)
 				echo When the files were encrypted
	   			 read RaChdate  
             cat $LPP/systemlog | grep -e "$RaChdate" | grep "Malware Remover" | grep -e "mover fr" -e "compl"

             press_enter
           
             ;;
         5)
            cat $LPP/systemlog | grep Photo | grep Updated

        press_enter
        ;;



                *)
        echo "Not supported"
        exit 1
        ;;
        esac






# cat $Path/sysmlog 


}

LVM_information(){


LVM_questions
LVM_input
 





}


LVM_questions(){

		echo question:
        echo 1. lvs -a
        echo 2. lvdisplay
        echo 3. pvs
        echo 4. snapshot.conf
        printf "\n"
        printf "\n"
        echo q. Leave
        printf "\n"
        echo Input Number:

        read LVANS
     

}


LVM_input(){


		case $LVANS in
		1)
		clear 

		echo lvs -a
		
         cat $LPP/lvs | grep -E '^|\-M\-'  --color=auto
        # cat $LPP/lvs | grep -E '^|Cwi'  --color=auto
        o
		press_enter 
		LVM_information

		;;
		2)
        clear

        echo lvdisplay
        cat $LPP/lvdisplay
		#cat $Path/Q*.html| grep "lvdisplay --map" -A  800 | grep -e "LV Path" -e "LV Name" -e "Type" -e "---\ L" -e "LV Creation host, time"| grep -v "Enclosure"

		press_enter 
		LVM_information
		;;

        3)
        clear 

        echo pvs -a 
        cat $LPP/pvs

        press_enter 
        LVM_information

        ;;


        4)
        clear 

        echo pvs -a 
        cat $Path/etc/config/qsnapshot/snapshot.conf

        press_enter 
        LVM_information

        ;;


		q)

		;;


		 *)
        echo "Not supported"
        
        ;;
esac


}


ZFS_information(){


ZFS_questions
ZFS_input
 




}


ZFS_questions(){

        echo question:
        echo 1. zfs get all
        echo 2. zfs type
        echo 3. zpool status
        echo 4. zfs volume information
        echo 5. Advanced ZFS information


        printf "\n"
        printf "\n"
        echo q. Leave
        printf "\n"
        echo Input Number:

        read ZFANS
     

}


ZFS_input(){


        case $ZFANS in
        1)
        clear 

        echo zfs get all
        cat $LPP/zfsgetall

        press_enter 
        ZFS_information

        ;;
        2)
        clear

        echo zfs type
        cat $Path/Q*.html| grep -i "zfs get all" -A 1500 | grep zpool1 | grep -v "202*-"| grep -v init | grep -v Snap | grep -e "\ refreservation" -e volume_name -e creation -e "\ refquota"
        printf "\n"
        printf "\n"
        echo refreservation none means thin volume

        press_enter 
        ZFS_information
        ;;

        3)
        clear 

        echo zpool list
        cat $Path/Q*.html| grep -i "=\ \[\ zpool list" -A 5 | grep -e NAME -e ONLINE -e OFFLINE -e pool -e state -e scan -e prune | grep -v =
        printf "\n"
        echo zpool status 
        cat $Path/Q*.html| grep -i "=\ \[\ zpool status -d" -A 20 | grep -e NAME -e ONLINE -e OFFLINE -e pool -e state -e scan -e prune | grep -v =

        press_enter 
        ZFS_information

        ;;

        4)
        clear 

        echo zfs get all
       

       


# cat $LPP/zfsgetall | grep -w "used\|usedbydataset\|usedbysnapshots\|refreservation\|qnap:zfs_volume_name\|refquota\|snap_refreservation" | grep -v "@snapshot\|@:init\|RecentlySnapshot"
cat $LPP/zfsgetall | grep -w "used\|usedbydataset\|usedbysnapshots\|refreservation\|qnap:zfs_volume_name\|refquota\|snap_refreservation\|qnap:pool_flag" | grep -v "@snapshot\|@:init\|RecentlySnapshot\|zpool1\ " | sed 's/zpool1\///' | sed 's/\:/_/' |sed 's/zfs//' | sort -nk1

 press_enter 
        ZFS_information

        ;;


        5)
        clear 


####
       
clear
source $LPP/qzfs_parameter
#lp_VolumeNumber=$(cat qvolume_parameter | grep -i mappingName |wc -l)
# 1 2 3 4 18 19 21 22 23 24 26 27 28 530 531 1107 1108 %

#for (( i=1; i<=$lp_VolumeNumber; i=i+1 ));
#ZFS_DefaultVolNumber=$(cat $LPP/qzfs_parameter | grep -e "ZFS[1-9]\_refquota"|wc -l)
#ZFS_VolNumber=$(($(cat $LPP/qzfs_parameter | grep -e "ZFS[1-3][0-9]\_refquota"|wc -l)+17))
#ZFS_AppVolNumber=$(($(cat $LPP/qzfs_parameter | grep -e "ZFS53[0-9]\_refquota"|wc -l)+529))
#ZFS_SystemVolNumber=$(($(cat $LPP/qzfs_parameter | grep -e "ZFS110[7-9]\_refquota"|wc -l)+1106))

#for (( i=18; i<$ZFS_volnumber+18; i=i+1 ));

#VolArray=($(seq 1 $ZFS_DefaultVolNumber) $(seq 18 $ZFS_VolNumber) $(seq 530 $ZFS_AppVolNumber) $(seq 1107 $ZFS_SystemVolNumber))
#for str in ${VolArray[@]}; do
#  echo $(ZFS!{str}_refquota)
#done

#for i in $(seq 1 $ZFS_DefaultVolNumber) $(seq 18 $ZFS_VolNumber) $(seq 530 $ZFS_AppVolNumber) $(seq 1107 $ZFS_SystemVolNumber)

k=""

for i in $(cat $LPP/zfs_info | tr -s " "|awk '{print $1}' | sort -nu | tr "\n" " ")




do 
echo "#######"
echo "zfs$i on $(cat $LPP/zfsgetall | awk '{print $1}' | sort -u | grep -v "@\|Re\|3[0-9]/"|grep -w zfs$i | cut -d "/" -f1 )"

ZFSVolumeName="ZFS${i}_qnap_zfs_volume_name"
ZFSRefreservation="ZFS${i}_refreservation"
ZFSRefquota="ZFS${i}_refquota"
ZFSSnapRefreservation="ZFS${i}_snap_refreservation"
ZFSUSED="ZFS${i}_used"
ZFSUSEDBYDATASET="ZFS${i}_usedbydataset"
ZFSUSEDBYSNAPSHOTS="ZFS${i}_usedbysnapshots"
ZFSOVERWRITEReservation="ZFS${i}_overwrite_reservation"





#echo Volume $i/$lp_VolumeNumber
echo "Shared Folder Name: ${!ZFSVolumeName}"
echo "Shared Folder Capacity: ${!ZFSRefquota}"

printf "\n"
printf "\n"




case ${!ZFSRefreservation} in
none)
echo This is a thin shared folder 
echo "Refreservation: ${!ZFSRefreservation}"
echo "Snap_Refreservation: ${!ZFSSnapRefreservation}"
echo "Used: ${!ZFSUSED}"
echo "Usedbydataset: ${!ZFSUSEDBYDATASET} "
echo "Usedbysnapshots: ${!ZFSUSEDBYSNAPSHOTS}"
echo "OverwriteReservation: ${!ZFSOVERWRITEReservation}"
printf "\n"
echo "Used Pool Size = Used by Data + Used by Snapshots" 
echo "${!ZFSUSED} = ${!ZFSUSEDBYDATASET} + ${!ZFSUSEDBYSNAPSHOTS}" 
printf "\n"

;;

*)

echo This is a thick shared folder
echo "Refreservation: ${!ZFSRefreservation}"
echo "Snap_Refreservation: ${!ZFSSnapRefreservation}"
echo "Used Pool Size: ${!ZFSUSED}"
echo "Used by data: ${!ZFSUSEDBYDATASET} "
echo "Used by snapshots: ${!ZFSUSEDBYSNAPSHOTS}"
echo "OverwriteReservation:: ${!ZFSOVERWRITEReservation}"


printf "\n"


 if [ $(cat $LPP/zfsgetall | grep -i zfs$i\@snap | grep creation | wc -l) = 0 ] ;
 # if [ $abc=0 ];

 then
echo snapshot hasn\'t created
echo "Used Pool Size = Refresevation + Snap Refreservation" 
echo "${!ZFSUSED} = ${!ZFSRefreservation} + ${!ZFSSnapRefreservation}" 


else


echo snapshot is created

echo "Used Pool Size = Refresevation + Snap Refreservation  + OverwriteReservation"
echo "${!ZFSUSED} = ${!ZFSRefreservation} + ${!ZFSSnapRefreservation} + ${!ZFSOVERWRITEReservation}"

fi


printf "\n"
printf "\n"



esac

#j=$i+$j
#k="${!ZFSUSED} $k"
#echo $j
#echo $k

echo Press enter to process:
read anything
clear
done




#####
 press_enter 
        ZFS_information

        ;;







        q)

        ;;


         *)
        echo "Not supported"
        
        ;;
esac


}

Open_files(){

#        
        echo question:
        echo 1. Open Html
        echo 2. Open Folders
        echo 3. Open Product Page
        echo 4. Open Firmware Page
        printf "\n"
        printf "\n"
        echo q. Leave
        printf "\n"
        echo Input Number:

        read OFANS



    case $OFANS in
        1)
        clear 

        echo open html: $Path/Q*.html
        Open $Path/Q*.html


        press_enter 
        Open_files

        ;;
        2)
        clear

        
        echo open folder: $Path
        Open $Path/


        press_enter 
        Open_files
        ;;
        3)
        clear 

        #open https://www.qnap.com/en/compatibility

        #purl='https://www.qnap.com/en/product/'$lp_Model
        purl='https://www.qnap.com/en/product/'$(echo $lp_Model | tr -d '\r')
        echo $purl
        Open $purl
        

        press_enter 
        Open_files

        ;;

        4)
        clear 

        #open https://www.qnap.com/en/compatibility

        durl='https://www.qnap.com/en/download?model='$(echo $lp_Model | tr -d '\r')

        echo $durl

        Open $durl
        

        press_enter 
        Open_files

        ;;


        q)
        ;;


         *)
        echo "Not supported"
        
        ;;
esac
}




helpdesk_information(){


helpdesk_questions
helpdesk_input


}


helpdesk_questions(){

#        
        echo question:
        echo 1. Previous ticket and remote sessions opened by helpdesk 
        echo 2. Display helpdesk log
        printf "\n"
        printf "\n"
        echo q. Leave
        printf "\n"
        echo Input Number:

        read TSANS


}
helpdesk_input(){



    case $TSANS in
        1)
        clear 


           echo $( cat $LPP/appinfo | grep -i helpdesk | awk '{print $1" "$4}')


            cat $LPP/systemlog | grep -i -e "Q-202" | awk -F "," '{print $3,$8}'





        press_enter 
        helpdesk_information

        ;;
        2)
        clear

        cat $Path/mnt/ext/opt/qdesk/www/data/log/log*

        echo testoutput



        press_enter      
        helpdesk_information
        ;;
        q)
        ;;


         *)
        echo "Not supported"
        
        ;;
esac



}














#######test##########test##########################test##########test#########################test##########test##################
 
 
 






Test_function(){


Test_questions
Test_input


}


Test_questions(){

#        
        echo question:
        echo 1. test_input
        echo 2. test_output
        printf "\n"
        printf "\n"
        echo q. Leave
        printf "\n"
        echo Input Number:

        read TSANS


}
Test_input(){



	case $TSANS in
		1)
		clear 

		echo test_input

#######test###
 
#cat $Path/tmp/.porter.log  | grep "generate_device_package_list" | sed 's/\ \}\,\ /\n/g'| tr "{" " "| tr "\"" " "
#echo get latest app version via QTS version
#QTSB=(`echo $lp_Firmware |cut -d "_" -f 1`);echo $QTSB
#echo $lp_platform
#curl https://download.qnap.com/Liveupdate/QTS$QTSB/qpkgcenter_eng.xml | grep zip | sort -u | grep -e $lp_platform -e master| grep -v HDV3 |sed -e 's/<[^>]*>//g' | sed 's/" "//g'

for (( i=1; i<=$lp_DiskNumber; i=i+1 ));
do 

        if grep -q "4\$" $Path/tmp/smart/smart_0_${lp_PortID[i]}.info ; then
            #printf "\e[1;34mThis is a blue text.\e[0m\n"
            echo $i/$lp_DiskNumber, Disk model: ${lp_DiskName[i]}, System Name: ${lp_SysName[i]}
            printf "\e[0;31mDisk Warning!!\e[0m\n"
            #echo "ATA bus error!!"
        else
            :
        fi
done



#######test###

		press_enter 
		Test_function

		;;
		2)
        clear
#cat $LPP/systemlog | awk -F\, '{ if ($2==1){print "\033[33m"w"\033[33m" $0   } else if ($2==2){print "\033[35m"e"\033[35m" $0} else if ($2==0){print "\033[39"n"\033[39m" $0}     }'
     
cat $LPP/systemlog |  sed 's/ML,\ /ML\ /' | awk -F, '{print $6,$17}'| grep -v "\-\-\-" | sort -u 

cat $LPP/accesslog|  sed 's/ML,\ /ML\ /' |awk -F, '{print $6,$14}'|  grep -v "\-\-\-" | sort -u
       

        echo testoutput

        



		press_enter 
		Test_function
		;;
		q)
		;;


		 *)
        echo "Not supported"
        
        ;;
esac



}

#######test##########test##########################test##########test#########################test##########test##################
 
 

#Test_function(){


#echo this is a test funcion


#}


#### error checking #####

Atabus_Error_Checking(){

        if grep -q "ATA bus error" $LPP/kernellog; then
            #printf "\e[1;34mThis is a blue text.\e[0m\n"
            bus_er_date=$(grep "ATA bus error" $LPP/kernellog | tail -n 1 | grep -o "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]")
       
            printf "\e[0;31mLatest ATA bus error!! on $bus_er_date\e[0m\n"
            
            #echo "ATA bus error!!"
        else
            :
        fi

}
Media_error_Checking(){
    
        if grep -q "media error" $LPP/kernellog; then
            mda_er_date=$(grep "media error" $LPP/kernellog | tail -n 1 | grep -o "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]")
            printf "\e[0;31mLatest Media error!! on $mda_er_date\e[0m\n"
        else
            :
        fi
}


IO_error_Checking(){
    
        if grep -q "I/O error" $LPP/kernellog; then
        io_er_date=$(grep "I/O error" $LPP/kernellog | tail -n 1 | grep -o "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]")    
        printf "\e[0;31mLatest I\O error!! on $io_er_date\e[0m\n"
        #echo "I/O error!!"
        else
            :
        fi
}

Call_trace_Checking(){
    
        if grep -q "Call Trace:" $LPP/kernellog; then
        call_trace_date=$(grep "Call Trace:" $LPP/kernellog | tail -n 1 | grep -o "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]")    
        printf "\e[0;31mLatest Call Trace on $call_trace_date\e[0m\n"
        #echo "I/O error!!"
        else
            :
        fi
}



Pool_error_checking(){


        if grep -q "\-M\-" $LPP/lvs; then
        printf "\e[0;31mPool readonly, needs TP_collect (lvs)\e[0m\n"
        #echo "I/O error!!"
        else
            :
        fi

}

UnknownDevice_error_checking(){


        if grep -q "a\-m" $LPP/pvs; then
        printf "\e[0;31mUnknown Device (pvs)\e[0m\n"
        #echo "I/O error!!"
        else
            :
        fi

}



Disk_Warning_Abnormal_Checking(){

    for (( i=1; i<=$lp_DiskNumber; i=i+1 ));
do 

        if grep -q "4\$" $Path/tmp/smart/smart_0_${lp_PortID[i]}.info ; then
            #printf "\e[1;34mThis is a blue text.\e[0m\n"
            printf "\e[0;31mDisk Warning\e[0m "
            echo \($i/$lp_DiskNumber\), Disk model: ${lp_DiskName[i]}, System Name: ${lp_SysName[i]}
            
            #echo "ATA bus error!!"
        else
            :
        fi
done

}

fcorig_error_checking(){


        if grep -q "owi-a-C" $LPP/lvs; then
        printf "\e[0;31mFcorig issue\e[0m\n"

        echo "https://ieinet.sharepoint.com/sites/GlobalSupportTeam/Shared%20Documents/General/TSD%20Knowledgebase/_06%20-%20Standard%20Procedures%20(SOP)/Fcorig%20issue%20sop%20V7.pdf"
        #echo "I/O error!!"
        else
            :
        fi



}

ReadDelete_error_checking(){


        if grep -q "status\=72" $LPP/qvolume_parameter; then
        printf "\e[0;31mRead/Delete\e[0m\n"

         #RDTP_name=`cat $LPP/qvolume_parameter  | grep "status\=72" -A 4 | grep baseId| cut -d "=" -f2`
         #echo $RDTP_name
         #cat $LPP/lvdisplay| grep tp$RDTP_name -B 5 -A 6 | grep _tmeta  -B 5 -A 6 | grep -e "LV Name" -e "Allocated pool" | sed 's/\ \ Allocated\ pool\ data/allocated/g' | sed 's/\ \ Allocated\ pool\ chunks/chunk/g'| tr -d ".,%,\r"|sed 's/\ \ LV\ Name/tpname/g' |  tr -s " "| tr " " "=" > $LPP/tp_remainsize
         cat $LPP/lvdisplay| grep "tp[0-9]_tmeta" -B 5 -A 6 | grep -e "LV Name" -e "Allocated pool" | sed 's/\ \ Allocated\ pool\ data/allocated/g' | sed 's/\ \ Allocated\ pool\ chunks/chunk/g'| tr -d ".,%,\r"|sed 's/\ \ LV\ Name/tpname/g' | tr -s " "| tr " " "=" > $LPP/tp_remainsize
         #chmod 755 $LPP/tp_remainsize
         #source $LPP/tp_remainsize
         tp_looptime=$((`cat $LPP/tp_remainsize | wc -l`/3))
     
awk 'NR%3==1{x="F"++i;}{print > x}' $LPP/tp_remainsize
   for (( i=1; i<=$tp_looptime; i=i+1 ));
do 

    source F$i
    chmod 755 F$i
   tp_remainsizeuse=$((((10000*$chunk/$allocated)-$chunk)*512/1024/1024))

   if (($tp_remainsizeuse<16));then 
      echo $tpname has only $tp_remainsizeuse GB remains
      
   else

      :

   fi   

done



        # * free TP size = X x (10000-y)/y x 512 /1024/1024
         #echo $allocated
         #echo $chunk
         #echo $((((10000*$chunk/$allocated)-$chunk)*512/1024/1024))GB
        
        #echo $(((10000-$allocated)/$chunk))
        #xxx=8338
        #yyy=659399
        #echo $xxx
        #echo $yyy

        #echo $(($yyy*(10000-$xxx)*512/1024/1024/$xxx))GB
        #echo  $yyy, 
        #echo $zzz
       
        #bcd=178
        #x=`echo $xxx | bc`
        #echo $x
        #echo $xxx
        #echo $(($x))
        #echo "I/O error!!"
        else
            :
        fi

}

QSA2224_checking(){
if grep -q Photo $LPP/appinfo; then 
    #printf "\e[0;31mPhoto Station installed\e[0m\n" 
    grep "PhotoStation\ " $LPP/appinfo | awk '{print $1" "$4": QSA-22-24"}'

    case $QTSv_shortform in
5.0.1)

echo Photo Station needs to be 6.1.2 and later
;;
5.0.0)

echo Photo Station needs to be 6.0.22 and later
;;

4.5.*)

echo Photo Station needs to be 6.0.22 and later
;;

4.3.6)

echo Photo Station needs to be 5.7.18 and later
;;

4.3.3)

echo Photo Station needs to be 5.4.15 and later
;;

4.2.6)

echo Photo Station needs to be 5.2.14 and later
;;

esac



    ##echo QTS 5.0.1: Photo Station 6.1.2 and later
    ##echo TS 5.0.0/4.5.x: Photo Station 6.0.22 and later
    ##echo QTS 4.3.6: Photo Station 5.7.18 and later
    ##echo QTS 4.3.3: Photo Station 5.4.15 and later
    ##echo QTS 4.2.6: Photo Station 5.2.14 and later


else
:
fi
}

Pstore_checking(){

ls $Path/sys/fs/pstore/console* 1>/dev/null 2>&1
if [ $? -ne 0 ]
then

    :
else
    printf "\e[0;31mPSTORE log found\e[0m\n"
fi


}


eth0_checking(){


        if grep -q "eth0" $LPP/network; then
        :
        else
            printf "\e[0;31mNo NIC eth0: WOL issue \e[0m\n"
        #echo "I/O error!!"
        fi

}

Upgrade_Memory_checking(){

    RAMupgraded=$(cat $LPP/kernellog  |grep Memory:  | cut -d \( -f1 |cut -d \/ -f2 | sort -u |wc -l)
        #echo $RAMupgraded

        if [ $RAMupgraded -eq 1 ]; then
        :
        else
            printf "\e[0;31mRAM upgraded before(or NAS migrated before)\e[0m\n"
            #cat $LPP/kernellog  |grep Memory:  | cut -d \( -f1 |cut -d \/ -f2 | sort -u
        
        fi

}

Mounted_DATA_checking(){


        if grep -q "DATA" $LPP/df; then
        :
        else
            printf "\e[0;31mNo DATA is mounted \e[0m\n"
        #echo "I/O error!!"
        fi

}



#echo The folder path:
#read Path
Path="$1"




resize -s 32 112 1>/dev/null 2>&1
ls $Path/Q*.html 1>/dev/null 2>&1
if [ $? -ne 0 ]
then

  echo Error: no Dianostic Log folder found
  printf "\n"
  echo Usage: sh log_parser.sh [folder_name_without space]
  echo for example: 
  echo sh log_parser.sh Q211I009382 
  printf "\n"
  exit
  
else
echo 
fi


# if [ $onQNAP -eq 0 ]; then 
# : 
#elif [ $onQNAP -eq 1 ]; then 
# :
# fi


  Generate_logs



#time Generate_logs
#press_enter

clear

while true; do
clear

echo "########################################"

if [ $onQNAP -eq 0 ]; then 

  echo READING: $Path `du -sh $Path | awk '{print " ","("$1")"}'`, $((($(date +%s) - $(stat -t %s -f %m -- $Path/Q*.html)) / 86400)) days old, $( cat $LPP/appinfo | grep -i helpdesk | awk '{print $1" "$4}')

  
elif [ $onQNAP -eq 1 ]; then 

echo READING: $Path

fi




# cat $Path/Q*.html | grep -e "Model:" -e "Firmware:" -e "Date:"
echo Date: $lp_Date
echo Model: $lp_Model
echo Firmware: $lp_Firmware

 if [ -z "$lp_QID" ];then
            : ## do nothing
            
        else
            echo myQNAPcloud URL: $myQNAPCloudUrl
 fi

ls $Path/etc/enclosure_0.conf 1>/dev/null 2>&1
if [ $? -ne 0 ]
then
  echo "Legacy model"
  modeltype=2
  
else
echo "$lp_ft, HAL model"
  modeltype=1
fi
 

## migrated by Diag and HAL
#if grep -q "Diag" $LPP/kernellog&&modeltype=1 ; then
#   echo migrated
#else
#    :
#fi



## migrated if two models history in kernel log


if [ -z "${modelhistory[2]}" ];then 
   :

else
   echo migrated, history ${modelhistory[1]},${modelhistory[2]}
fi




echo `cat $LPP/kernellog | tail -n 1 | awk '{print $5}'| sed 's/\[//g'|cut -f1 -d"."`| awk '{printf "Power on time: %dD:%dH:%dM (%d) \n",$1/(60*60*24),$1%(60*60*24)/(60*60),$1/60%60,$1}'




echo "########################################"

Disk_Warning_Abnormal_Checking
Atabus_Error_Checking
Media_error_Checking
IO_error_Checking
Pool_error_checking
UnknownDevice_error_checking
ReadDelete_error_checking
# QSA2224_checking
fcorig_error_checking
Call_trace_Checking
Pstore_checking
eth0_checking
Upgrade_Memory_checking
Mounted_DATA_checking








printf "\n"
echo What information do you need\?
printf "\n"
echo 1.   Basic information
echo 2.   Volume information
echo 3.   RAID information
echo 4.   APP information
echo 5.   Disk information
echo 6.   Shared Folders information
echo 7.   System log information
echo 8.   Kernel log information
echo 9.   Network information
echo 10. Memory information
echo 11. Cache information
echo 12. myQNAPcloud information
echo 13. Security information
echo 14. Process information
echo 15. RansomwareCheck information
echo 16. LVM information
echo 17. ZFS information
echo 18. Open files
echo 19. helpdesk information
echo 99. Test function

printf "\n"
echo Input Number:

read ANS
printf "\n"








case $ANS in
    
    99)  
        clear

        Test_function

        press_enter
        
        ;;

    "")  ## for no input
        clear
        
        ;;



    1)  
        clear

        time Basic_information

        press_enter
        
        ;;
    2)  
        clear
        
        Volume_information
        
        press_enter
        ;;
    3)
        clear
        
        RAID_information

        
        ;;
    4)
        clear
       
        APP_informaiton

        press_enter
        ;;

    5)
        clear

        Disk_information

        press_enter
        ;;
    6)
        clear
        
        Shared_folders_information

        press_enter
        ;;
    7)
        clear

        Systemlog_information

        #press_enter
        ;;


     9)
        clear

        Network_information

        press_enter
        ;;


     11)
        clear

        Cache_information

        press_enter
        ;;

      12)
        clear

        myQNAPcloud_information

        press_enter
        ;;  

  
       13)
        clear

        Security_information

        press_enter
        ;;  


  14)
        clear

        Process_information

        press_enter
        ;;  


  15)
        clear

        RansomwareCheck_questions

        RansomwareCheck_information_input

        press_enter
        ;;  


     16)


 		clear

       

        
		LVM_information

        #press_enter
     ;;  


     17)


        clear

       

        
        ZFS_information

        #press_enter
     ;; 






    18)


        clear

       

        
        Open_files

        press_enter
     ;;  



         19)


        clear

       

        
        helpdesk_information

        press_enter
     ;;  







    10)
        clear

        Memory_information

        press_enter
        ;;   


    8)
        clear

        Kernellog_questions

        Kernellog_input


        #press_enter
        ;;





    q)
        exit 1
        ;;







        *)
        echo "Not supported"
        exit 1
        ;;
esac


done
