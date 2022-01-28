#!/bin/bash

{ grep "OK DOWNLOAD" cdlinux.ftp.log | cut -d '"' -f 2,4 | sed 's/"/ /'; grep " 200 " cdlinux.www.log | cut -d " " -f 1,7 | cut -d ":" -f 2-9; } | sort | uniq | cut -d " " -f 2 | sed "s#.*/##" | grep ".iso" | sort | uniq -c