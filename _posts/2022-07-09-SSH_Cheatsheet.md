---
title: "SSH Cheat Sheet"
date: 2020-11-26
layout: single
excerpt: "Some Quick and Dirty SSH Commands"
classes: wide
header:
  #teaser:
  teaser_home_page: true
  #icon:
categories:
  - Cheatsheet
tags:
  - SSH
---

## SSH Konami Codes

- Create forwards after you connect

[konami](https://www.sans.org/blog/using-the-ssh-konami-code-ssh-control-sequences/)

## SSH Setup User that only is allowed to forward
- This user will also only use key based auth

## Sources
[One](https://askubuntu.com/questions/48129/how-to-create-a-restricted-ssh-user-for-port-forwarding)

[Two](https://unix.stackexchange.com/questions/14312/how-to-restrict-an-ssh-user-to-only-allow-ssh-tunneling)

[Three](https://serverfault.com/questions/285800/how-to-disable-ssh-login-with-password-for-some-users)

[Four](https://www.ssh.com/ssh/keygen/)

## Steps:

1. Create User

  ```
  useradd --shell /bin/bash username
  ```

2. Generate ssh keypair and upload
- Make sure to not password protect the key since this will be used in scripts

  ```
  ssh-keygen -f ~/.ssh/forwards.key -t ecdsa -b 521

  ssh-copy-id -i ~/.ssh/forwards.key user@host
  ```

3. Login as username with public key to make sure you have a shell and everything is working

4. Logout, Login as root and change "etc/passwd" shell for username to 

    ```
    /bin/false
    ```

5. lock down user in ssh_config, add this:

    ```
    Match User username
        PasswordAuthentication no
        PubkeyAuthentication yes
        PermitEmptyPasswords no
        GatewayPorts no
        X11Forwarding no
        AllowAgentForwarding no

        #Additional Options based off your config:
        #ForceCommand /bin/false
        #Disables "-R":
        #AllowTcpForwarding yes 
        #PermitOpen localhost:62222
        #PermitTunnel no
    ```

6. Restart SSH Server

7. username should now be only able to forward ports, verfiy by trying to do scp, sftp and direct commands with ssh.


---

## Setup SSH Key based authentication
1. use ssh-keygen to generate keys

    ```
    ssh keygen -f hello
    ```
    This will generate two files: "hello" and "hello.pub"
2. Copy public key ("hello.pub") to remote ssh server and concatinate it under user "authorized_hosts" file (/home/user/.ssh/authorized_hosts). Note: you can remove the comment at end so:

    This: 
    ```
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDK36LA/ZcqDF5RbVn9HQDpg3DWUFn97fcVEG+vlitoBzG0LlcFhty5NDARcnZluUTxcx0obY6WgjiQveKG63tT/M7p2zZlqw9QDj6a3vDvyEQ0/gc9We88fcd1oSFmkGuOOO2edim5NJZmzO+9+BLFlkB6KawH6pSiMkyYJ26apnMlyT+lLjQKaLFgsPpkwK0pExtDHTLUDUmtWMmoo+ZtuWPsw1Fozv6liiX3I29LQt5q7ZPBL8q1mlPdNIxePBJf/cGbdg4TvtbWOhrpQqzOv6azHRqKiymWhcO5LMKlv0LpnDnr1ggeOOZ1W6dXt9oVnZHnsgBF4GAKhzfrsPpK6pQcrx+Xcrozn60r5TFzSiBZ3qq1vJwSQYbwfA2oYrRjMORXmCO9qV4aby26BTfYWywGdFTHSYA394gPs7o/IqAfFeKDId5R2oNPKeON9EIBTkrWDxQ95L3CbCP2RS0azcuyEfzOS51xPlFEHoap2OKSJmb7tPVKb5zt1/yiRoE= root@spooky
    ```
    Is equivalent to:

    ```
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDK36LA/ZcqDF5RbVn9HQDpg3DWUFn97fcVEG+vlitoBzG0LlcFhty5NDARcnZluUTxcx0obY6WgjiQveKG63tT/M7p2zZlqw9QDj6a3vDvyEQ0/gc9We88fcd1oSFmkGuOOO2edim5NJZmzO+9+BLFlkB6KawH6pSiMkyYJ26apnMlyT+lLjQKaLFgsPpkwK0pExtDHTLUDUmtWMmoo+ZtuWPsw1Fozv6liiX3I29LQt5q7ZPBL8q1mlPdNIxePBJf/cGbdg4TvtbWOhrpQqzOv6azHRqKiymWhcO5LMKlv0LpnDnr1ggeOOZ1W6dXt9oVnZHnsgBF4GAKhzfrsPpK6pQcrx+Xcrozn60r5TFzSiBZ3qq1vJwSQYbwfA2oYrRjMORXmCO9qV4aby26BTfYWywGdFTHSYA394gPs7o/IqAfFeKDId5R2oNPKeON9EIBTkrWDxQ95L3CbCP2RS0azcuyEfzOS51xPlFEHoap2OKSJmb7tPVKb5zt1/yiRoE=
    ```

3. On Remote Server, change the "/etc/ssh/sshd_config" option of "PasswordAuthentication" to "no" and restart sshd service:

    ```
    systemctl restart sshd
    ```
4. Change permissions of private key ("hello") to 600:

    ```
    chmod 600 hello
    ```
5. Now Connect to remote server like:

    ```
    ssh -i ./hello user@${REMOTE SERVER IP OR DNS}
    ```


---

## Local Forwards Basic:
- This will open a local port at 127.0.0.1:4321, everthing that is pushed to this port will be tunneled through 192.168.1.12 and pushed to 10.10.10.11:443

  ```
  ssh john@192.168.1.12 -L 4321:10.10.10.11:443
  ```

## Locally Expose SSH Tunnel for local forwards:
- This will open local ssh tunnel to all devices that can access client ssh device

  ```
  ssh john@192.168.1.12 -L 0.0.0.0:8500:10.10.10.23:8500 -N
  ```

## Locally access servies not exposed remotely on remote devices
- This will tunnel all traffic on port 4321 (local machine) to remote machine's (192.168.1.12) local service on port 443

  ```
  ssh john@192.168.1.12 -L 4321:127.0.0.1:443
  ```

## Remote Forwards Basic:
- This will open a port on remote host (192.168.1.12) listening on 127.0.0.1:4321. Any traffic that reaches this port will be fowarded back to local host (where the ssh command was originated from) and then sent out to 10.10.10.11:443. This is basically local forwarding but backwards

  ```
  ssh john@192.168.1.12 -R 4321:10.10.10.11:443
  ```
## Expose Remote port and use to access local services listening local only
- This will open a remote port listening for all accessable devices. Once this port is accessed it will forward traffic back to originating host (local host) and access a service that is only listening locally (on 127.0.0.1). 
- Make sure to set ssh config item (/etc/ssh/sshd_config) "GatewayPorts" to "yes" on ssh server 

  ```
  ssh john@192.168.1.12 -R 4321:127.0.0.1:443
  ```

## Remote Forward Remote Local Port to Local Local Port

  ```
  ssh john@192.168.1.12 -R 127.0.0.1:4321:127.0.0.1:443
  ```

## SSH Socks5 Proxy
- This will make use of the socks5 proxy feature openssh provides
- This is mostly useful for forwarding web browser requests thorugh a remote proxy'ed server in order to hide location
- Remember: THIS ONLY WORKS FOR TCP, UDP will silently fail
- This will create a local listening port at "2222" on local machine and forward all tcp requests using socks5 proxy thorugh 192.168.1.12

  ```
  ssh  -D 127.0.0.1:2222  john@192.168.1.12
  ```

## Connect SSH with Private key used only for forwards
- This can be used by scripts to creat a forward automatically
- It will also never record the "Known-Hosts" so you don't have to worry about server validation (unsecure however)
- Remote

  ```
  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2222 -N -R 127.0.0.1:2222:127.0.0.1:22 -i /root/.ssh/private_key user@172.13.13.26 &
  ```
- Local

  ```
  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2222 -N -L 0.0.0.0:8080:127.0.0.1:8080 -i /root/.ssh/private_key user@172.13.13.26 &
  ```
- Where:

  ```
  -o UserKnownHostsFile=/dev/null --> Disable host file
  -o StrictHostKeyChecking=no --> Don't check for Hostkey validation (unsecure)
  -p 2222 --> ssh server port number
  -N --> Do not create a session shell (only process forwards)
  -L --> Local Forwarding
  -R --> Remote Forwarding
  -i --> use private key
  & --> Run as Detached Process
  ```
