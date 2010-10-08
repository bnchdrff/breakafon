#!/bin/sh

# this helps!
# you'll have to delete previous ssh known_hosts entries for 169.254.255.1
# also, if it's an older fonera (0.7.0ish), change fondue to grammofon

echo -n 'mv /etc/init.d/dropbear /etc/init.d/S50dropbear' | perl xss-attacks/fondue.pl 169.254.255.1 admin
echo -n 'sh /etc/init.d/S50dropbear start' | perl xss-attacks/fondue.pl 169.254.255.1 admin

scp ./flash-images/openwrt-ar531x-2.4-vmlinux-CAMICIA.lzma root@169.254.255.1:/tmp/
ssh root@169.254.255.1 'cd /tmp ; mtd -e vmlinux.bin.l7 write openwrt-ar531x-2.4-vmlinux-CAMICIA.lzma vmlinux.bin.l7'
ssh root@169.254.255.1 'sync && reboot'
scp ./flash-images/out.hex root@169.254.255.1:/tmp/
ssh root@169.254.255.1 'cd /tmp && cp /dev/mtd/5 /tmp/mtd5 && cp /dev/mtd/6 /tmp/mtd6'
ssh root@169.254.255.1 'cd /tmp && mtd erase "FIS directory" && cat mtd5 >/dev/mtd/5 && cat out.hex >/dev/mtd/6 && sync && md5sum out.hex /dev/mtd/6 mtd5 /dev/mtd/5'
sudo ./open-mesh-flash  eth0

