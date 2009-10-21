#!/bin/bash
DIR=

FILES=( \
/etc/fstab /etc/paludis /etc/conf.d /etc/cron.daily /etc/env.d/99personal /etc/logrotate.d /etc/sysctl.conf \
/etc/rc.conf /etc/resolv.conf /etc/rsyslog.conf /etc/samhainrc /etc/security/limits.conf /etc/smartd.conf /etc/vim/vimrc.local \
/boot/kern.config /boot/grub/{escher.xpm.gz,grub.conf} /root/.toprc /home/nwmcsween/.gitconfig /usr/local/bin/insecure \
/usr/local/sbin/{analyze-x86,checksec,instkern}
)


for i in "${FILES[@]}"; do
    if [[ ! -a ./${DIR}/${i} ]]; then
        echo ${i}
    fi
    cp -R -L --parents /$i ./${DIR}
done
