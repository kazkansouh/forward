#!/bin/sh

# Copyright (C) 2020 Karim Kanso. All Rights Reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# generate a new private key each time container is started
su forward -s /bin/sh -c "ssh-keygen -C forward@forward -N '' -t ecdsa -f /home/forward/.ssh/id && mv /home/forward/.ssh/id.pub /home/forward/.ssh/authorized_keys"

# set forward account password
if test -f /.nopass ; then
    PASS=$(dd if=/dev/urandom bs=8 count=1 status=none | xxd -p)
    (
        echo ${PASS}
        echo ${PASS}
    ) | passwd forward
    echo ${PASS} > /password
fi

# generate new host keys
ssh-keygen -A

# start ssh
/usr/sbin/sshd -D
