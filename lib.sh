#!/bin/bash

function hosts()
{
	hostsIp=$1
	hostsDomain=$2
	sed -i "" "/$hostsDomain/d" /etc/hosts
	if [ "$hostsIp" != 'remove' ]; then
		echo "$hostsIp $hostsDomain" >> /etc/hosts
	fi
}

function playAndVerify()
{
	rm temp.flv
	nohup ./rtmpdump -r $1 -o temp.flv > /dev/null &
	sleep 10
	fileSize=`ls -l temp.flv | awk '{print $5}'`

	ps -ef | grep $1 | grep rtmpdump | grep -v grep | awk '{print $2}' | xargs kill -9
	#pids=`ps -ef | grep $1 | grep ./ffmpeg_bin/ffmpeg | grep -v grep | awk '{print $2}'`

	echo $fileSize
}