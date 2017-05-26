FROM debian:stretch
MAINTAINER Steffen Vinther Sørensen <svinther@gmail.com>

# Install samba
RUN export DEBIAN_FRONTEND='noninteractive' && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends procps samba samba-vfs-modules\
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    useradd -c 'Samba User' -d /tmp -M -r smbuser && \
    sed -i 's|^\(   log file = \).*|\1/dev/stdout|' /etc/samba/smb.conf && \
    sed -i 's|^\(   unix password sync = \).*|\1no|' /etc/samba/smb.conf && \
    sed -i '/Share Definitions/,$d' /etc/samba/smb.conf && \
    echo '   security = user' >>/etc/samba/smb.conf && \
    echo '   create mask = 0664' >>/etc/samba/smb.conf && \
    echo '   force create mode = 0664' >>/etc/samba/smb.conf && \
    echo '   directory mask = 0775' >>/etc/samba/smb.conf && \
    echo '   force directory mode = 0775' >>/etc/samba/smb.conf && \
    #echo '   force user = smbuser' >>/etc/samba/smb.conf && \
    echo '   force group = users' >>/etc/samba/smb.conf && \
    echo '   follow symlinks = yes' >>/etc/samba/smb.conf && \
    echo '   load printers = no' >>/etc/samba/smb.conf && \
    echo '   printing = bsd' >>/etc/samba/smb.conf && \
    echo '   printcap name = /dev/null' >>/etc/samba/smb.conf && \
    echo '   disable spoolss = yes' >>/etc/samba/smb.conf && \
    echo '   socket options = TCP_NODELAY' >>/etc/samba/smb.conf && \
    echo '   strict locking = no' >>/etc/samba/smb.conf && \
    echo '   vfs objects = recycle' >>/etc/samba/smb.conf && \
    echo '   recycle:keeptree = yes' >>/etc/samba/smb.conf && \
    echo '   recycle:versions = yes' >>/etc/samba/smb.conf && \
    echo '[users]' >>/etc/samba/smb.conf && \
    echo '   path = /srv' >>/etc/samba/smb.conf && \
    echo '   browsable = no' >>/etc/samba/smb.conf && \
    echo '   read only = no' >>/etc/samba/smb.conf && \
    echo '   guest ok = no' >>/etc/samba/smb.conf && \
    echo '   veto files = /._*/.apdisk/.AppleDouble/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/' >>/etc/samba/smb.conf && \
    echo '   delete veto files = yes' >>/etc/samba/smb.conf && \
    echo '   valid users = +users' >>/etc/samba/smb.conf && \
    echo '' >>/etc/samba/smb.conf && \
    chgrp users /srv && \
    chmod 775 /srv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*
COPY samba.sh /usr/bin/

VOLUME ["/etc/samba"]

EXPOSE 137/udp 138/udp 139 445

ENTRYPOINT ["samba.sh"]