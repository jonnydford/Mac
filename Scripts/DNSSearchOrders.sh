#!/bin/bash

/usr/sbin/networksetup -setsearchdomains Wi-Fi domain1.local domain2.local domain3.local
/usr/sbin/networksetup -setsearchdomains "Thunderbolt Ethernet" domain1.local domain2.local domain3.local
/usr/sbin/networksetup -setsearchdomains Ethernet domain1.local domain2.local domain3.local

exit 0