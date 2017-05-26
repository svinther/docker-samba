FROM centos:7
MAINTAINER Steffen Vinther Sørensen <svinther@gmail.com>

#RUN yum -y update && \
#    yum -y install samba && \
#    yum clean all

RUN yum -y install samba which && yum clean all

# Install samba
RUN useradd -c 'Samba User' -d /tmp -M -r smbuser && \
    chgrp users /srv && \
    chmod 775 /srv 

COPY smb.conf /etc/samba
COPY samba.sh /usr/bin/

VOLUME ["/etc/samba"]

EXPOSE 137/udp 138/udp 139 445

ENTRYPOINT ["samba.sh"]
