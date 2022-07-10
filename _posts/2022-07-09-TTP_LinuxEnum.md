---
title: "TTP Linux Basic Enum"
date: 2020-11-26
layout: single
excerpt: "5 Simple Things To Enumerate Once Inside a Linux Box"
classes: wide
header:
  #teaser:
  teaser_home_page: true
  #icon:
categories:
  - TTP
tags:
  - Enmuration
  - Linux
---

**Purpose:** 
- This will show 5 basic tasks to complete once user is gained on a linux-based machine. This meant for basic enumeration but is a good place to start

**Tested/Verified on:**
- HTB Easy Boxes

**Tools:**

**Created On: 07/09/2022**

**Last Updated: 07/09/2022**


---

1. Verify Sudo

```bash
#ACTION:

sudo -l

#PASS:
- No password prompt
- "run the following commands" will be "(ALL) ALL" or Other commands

#FAIL:
- Password Prompt
- No Commands specified for user with sudo

```

2. Check Root Processes

```bash
#ACTION:

ps auxwe | grep root

#PASS:
- All Root Processes are displayed with full command paths


#FAIL:
- No Root Processes are displayed or output format is unreadable

```

3. Check what is listening on system

```bash
#ACTION:

ss -tln

#PASS:
- All listening processes are displayed

#FAIL:
- All listening processes are not displayed


```

4. Search for all readable SUID files

```bash

#ACTION:

find / -perm -u=s -type f 2>/dev/null

#PASS:
- SUID files are displayed

#FAIL:
- SUID files are not displayed


```

5. Search for Kernel and OS Version

```bash
#ACTION:

uname -a

#PASS:
- Info is displayed

#FAIL:
- Info is not displayed

#ACTION:

cat /etc/*release*

#PASS:
- Info is displayed

#FAIL:
- Info is not displayed

```