#!/system/bin/sh
# Remount filesystems RW
busybox mount -o remount,rw / /
busybox mount -o remount,rw /dev/block/mmcblk0p24 /system
busybox --install -s /system/bin
busybox --install -s /system/xbin
busybox ln -s /sbin/busybox /system/bin/busybox
chmod 06755 /sbin/su
busybox rm /system/bin/su
busybox rm /system/xbin/su
busybox rm /system/bin/jk-su
busybox cp -f /sbin/su /system/bin/su
busybox ln -s /system/bin/su /system/xbin/su
busybox rm -rf /bin/su
busybox rm -rf /sbin/su

if [ ! -f "/system/app/Superuser.apk" ] && [ ! -f "/data/app/Superuser.apk" ] && [[ ! -f "/data/app/com.noshufou.android.su"* ]]; then
 	busybox cp /sbin/superuser.apk /system/app/superuser.apk
 fi
busybox rm /sbin/superuser.apk
sync
# Enable init.d support
if [ -d /system/etc/init.d ]
then
	logwrapper busybox run-parts /system/etc/init.d
fi
sync

#setup proper passwd and group files for 3rd party root access
# Thanks DevinXtreme

if [ ! -f "/system/etc/passwd" ]; then
	echo "root::0:0:root:/data/local:/system/bin/sh" > /system/etc/passwd
	chmod 0666 /system/etc/passwd
fi
if [ ! -f "/system/etc/group" ]; then
	echo "root::0:" > /system/etc/group
	chmod 0666 /system/etc/group
fi
# fix busybox DNS while system is read-write
if [ ! -f "/system/etc/resolv.conf" ]; then
	echo "nameserver 8.8.8.8" >> /system/etc/resolv.conf
	echo "nameserver 8.8.4.4" >> /system/etc/resolv.conf
fi
sync
# patch to prevent certain malware apps
if [ -f "/system/bin/profile" ]; then
	busybox rm /system/bin/profile
fi
touch /system/bin/profile
chmod 644 /system/bin/profile
if [ -f "/system/media/bootanimation.zip" ]; then
ln -s /system/media/bootanimation.zip /system/media/sanim.zip
fi
# remount read only and continue
busybox  mount -o remount,ro / /
busybox  mount -o remount,ro /dev/block/mmcblk0p24 /system
