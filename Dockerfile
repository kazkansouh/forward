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

FROM alpine:3.12

RUN apk --no-cache add openssh-server

RUN sed -i -E \
        -e "s/^(# *)?(PermitRootLogin).*$/\2 no\nAllowUsers forward/" \
        -e "s/^(# *)?(AllowTcpForwarding).*$/\2 yes/" \
        -e "s/^(# *)?(GatewayPorts).*$/\2 yes\nPermitOpen none/" \
        -e "s/^(# *)?(ClientAliveInterval).*$/\2 60/" \
        -e "s/^Subsystem/# \0/" \
        /etc/ssh/sshd_config

EXPOSE 22/tcp

# configure password and tag image with password so "docker inspect"
# reveals it.
ARG PASSWORD=UNDEFINED
LABEL PASSWORD=$PASSWORD
RUN if test "UNDEFINED" = "${PASSWORD}" ; then \
        touch /.nopass ; \
        adduser forward -D -s /sbin/nologin ; \
     else \
        ( \
            echo "${PASSWORD}"; \
            echo "${PASSWORD}"; \
        ) | adduser forward -s /sbin/nologin ; \
    fi

ADD start.sh /
CMD "/start.sh"
