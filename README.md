# Simple Samba server with 1 share and support for users

* Based on CentOS 7 
* Optional nmbd

## Example use

    docker volume create --name samba
    docker run --name samba -v samba:/srv -it -p 139:139 -p 445:445 -d samba 
    docker exec samba samba.sh -u "exampleuser;badpass" true 
## Maintainer

* Steffen Vinther Sørensen <svinther@gmail.com>


