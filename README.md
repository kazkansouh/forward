# SSH Docker for Reverse Forwarding

Alpine Docker image developed for reverse port forwarding from
untrusted computers. This is useful to take advantage of the SSH
inbuilt port forwarding capability without compromising security,
e.g. credentials issued on remote machine are not important.

The image provides minimal `sshd` service that listens on port 22 and
*only* allows the `forward` user with a password or key to connect
(see usage for details). This user is *only* able to request a reverse
forward, i.e. `-R ...`, that is they are configured with the shell
`/sbin/nologin` and `-L` port forwarding is not possible.

## Usage

First, the docker image needs to be built. This must be done locally
as the password for the `forward` user is defined at build time.

```
$ docker build --build-arg PASSWORD=MyPassword123 -t forward .
```

If the `--build-arg PASSWORD=MyPassword123` is omitted, every time the
container is started a new password will be generated and is
available to read from the file located at `/password`.

In addition, each time the container is started a new `ssh` private
key is generated. This is located at: `/home/forward/.ssh/id_ecdsa`
and needs to be manually extracted if its needed to be used.

Then the image can be used as follows:

```
$ docker run -p 2222:22 --rm --name forward forward
```

On the remote computer (Linux), to forward port 5678 to port 1234 on
the docker container (note, this must be a non-privileged port):

```
$ ssh forward@my.address.com -p 2223 -Nf -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -R 1234:localhost:5678
```

Similarly on a remote Windows:

```
> echo yes | plink -R 1234:localhost:5678 -P 2222 -N -pw MyPassword123 -ssh -v -l forward my.address.com
```

Afterwards, its possible to connect to port `1234` on the docker
container. At times, it also useful to place the port at the
expected location with an `iptables` rule:

```
$ iptables -t nat -A OUTPUT -d some.ip.ad.dr -p tcp --dport 5678 -j DNAT --to docker.cont.ainer.ip:1234"
```

### Scripting

To reduce the need of remembering all the above details, there is a
script `forward` that spins up the container and extracts the
password/private key use for connecting. It will also printout some
example commands that cover many use cases.

All that is needed is to place the script it on the path (and already
have built the image), and then when needing to reverse forward a port
just type `forward` and it will display the needed information. When
done with the container, type `forward exit` and it will kill the
container.

For example:

```
$ forward
Starting docker container: fb868dca9eec99c006adf10528d69655eab3580e2b7f8b8e668ea12e475b52a1
Docker ip address: 172.17.0.3
To connect use credentials forward:1a56a397ebf32df8 . Example commands:
  ssh forward@10.10.14.5 -p 2222 -Nf -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -R 3306:localhost:3306
  ssh forward@10.10.14.5 -p 2222 -Nf -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /tmp/id -R 4445:10.10.10.81:445
  echo y | Plink.exe -R 4445:localhost:445 -P 2222 -N -pw 1a56a397ebf32df8 -ssh -l forward 10.10.14.5 2>&1

If needed, use iptables to bounce connection:
  iptables -t nat -A OUTPUT -d 10.10.10.81 -p tcp --dport 445 -j DNAT --to 172.17.0.3:4445

forward's private key is
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAaAAAABNlY2RzYS
1zaGEyLW5pc3RwMjU2AAAACG5pc3RwMjU2AAAAQQQWM/YznOR8/OIO/wRmqhEQrIktFM+u
yVdXPMLTgWekVTPDi5DpwhfFl7urtETKX8XGo7U1h49mSvp+A0fKiGdWAAAAqDDJ+ZQwyf
mUAAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBYz9jOc5Hz84g7/
BGaqERCsiS0Uz67JV1c8wtOBZ6RVM8OLkOnCF8WXu6u0RMpfxcajtTWHj2ZK+n4DR8qIZ1
YAAAAhAKNmrNX1XfyeRX0ffTl9rcnJ/BKbsfx6mbG6ZTgylleGAAAAD2ZvcndhcmRAZm9y
d2FyZA==
-----END OPENSSH PRIVATE KEY-----
```

## Other Bits

Licensed under GPLv3. Copyright 2020. All rights reserved, Karim Kanso.
