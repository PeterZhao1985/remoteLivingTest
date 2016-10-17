#!/bin/bash

# 示例:
# 模拟域名：模拟从某域名或cname进行播放：./test.sh rtmp://xxx/xxx/xxx -d somedomain.qiniu.com -c configFile
# 模拟ip：模拟从某个ip进行播放：./test.sh rtmp://xxx/xxx/xxx -i xxx.xxx.xxx.xxx -c configFile
# 域名远程：从播放地址对应域名的该地区进行播放：./test.sh rtmp://xxx/xxx/xxx -c configFile

# configFile的作用是说明需要进行测试的区域，如果不填写则使用缺省的default.config，也就是全国三大运营商

source lib.sh
playUrl=$1
temp=${playUrl#*//}
domain=${temp%%/*}

if [ "$2" = '-d' ]; then
	fakedomain=$3
	mode='fakeDomain'
fi

if [ "$2" = '-i' ]; then
	ip=$3
	mode='fakeIp'
fi

if [ "$2" = '-c' ]; then
	configFile=$3
	mode='domainRemoting'
fi

if [ "$mode" = '' ]; then
	temp=${playUrl#*//}
	domain=${temp%%/*}
	mode='domainRemoting'
fi

if [ "$4" = '-c' ]; then
	configFile=$5
fi

if [ "$configFile" = '' ]; then
	configFile='default.config'
fi

echo 'Mode: '$mode
echo 'Play url: '$playUrl
echo 'Domain: '$domain
echo 'Ip: '$ip
echo 'Config file: '$configFile
echo '================================================='

if [ "$mode" = 'fakeIp' ]; then
	echo Play $playUrl with Ip $ip...
	hosts $ip $domain
	sleep 1
	result=`playAndVerify $playUrl`
	echo [Result] Recieved: $result
	hosts remove $domain
	exit
fi

while read scenario
do
    echo Scenario: $scenario
    province=${scenario% *}
    isp=${scenario#* }

    if [ "$mode" = 'fakedomain' ]; then
    	response=`curl -s "http://domain_spider.qiniudns.com/v1/resolve?domain=$fakeDomain&type=cname&province=$province&isp=$isp"`
	else
		response=`curl -s "http://domain_spider.qiniudns.com/v1/resolve?domain=$domain&type=cname&province=$province&isp=$isp"`
	fi

	temp=${response#*\"ip\":\"}
	ip=${temp%%\",*}
	echo Remote ip from fake domain: $ip
	if [ "$ip" != '' ]; then
		hosts $ip $domain
		sleep 1
		result=`playAndVerify $playUrl`
		echo [Result] Recieved: $result
		echo ------------------------------------------------
	fi
done < $configFile

hosts remove $domain
