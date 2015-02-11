#!/bin/sh

# this helps!
# you'll have to delete previous ssh known_hosts entries for 169.254.255.1
# also, if it's an older fonera (0.7.0ish), change fondue to grammofon
# fondue works for 0.7.1 r1

# BEFORE YOU START (but after you connect the fonera)
# set your ethernet interface to 169.254.255.2 netmask 255.255.0.0

# these two commands will jailbreak a 0.7.1-ish era fon 2100a/b/c
# before running these, plug in a powered Fon to your ethernet port
echo -n 'mv /etc/init.d/dropbear /etc/init.d/S50dropbear' | perl xss-attacks/grammofon.pl 169.254.255.1 admin
echo -n 'sh /etc/init.d/S50dropbear start' | perl xss-attacks/grammofon.pl 169.254.255.1 admin

# this copies the new firmware to the router and then flashes it
scp ./flash-images/openwrt-ar531x-2.4-vmlinux-CAMICIA.lzma root@169.254.255.1:/tmp/
ssh root@169.254.255.1 'cd /tmp ; mtd -e vmlinux.bin.l7 write openwrt-ar531x-2.4-vmlinux-CAMICIA.lzma vmlinux.bin.l7'
ssh root@169.254.255.1 'sync && reboot'

# wait a minute, then copy+flash the new bootloader
# check the md5 sums to make sure everything's kosher
sleep 120
scp ./flash-images/out.hex root@169.254.255.1:/tmp/
ssh root@169.254.255.1 'cd /tmp && cp /dev/mtd/5 /tmp/mtd5 && cp /dev/mtd/6 /tmp/mtd6'
ssh root@169.254.255.1 'cd /tmp && mtd erase "FIS directory" && cat mtd5 >/dev/mtd/5 && cat out.hex >/dev/mtd/6 && sync && md5sum out.hex /dev/mtd/6 mtd5 /dev/mtd/5'
#sudo ./open-mesh-flash  eth0

# done
echo 'done'

