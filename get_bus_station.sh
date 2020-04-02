#!/bin/bash

wxwork_hook="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxxxxxxxxxxxxxxxxxxxxxxxxx"

to_url="https://shanghaicity.openservice.kankanews.com/public/bus/Getstop?stoptype=0&stopid=5&sid=3213f7d0fbf77de08fae3a2f2a2d4dec"

return_url="https://shanghaicity.openservice.kankanews.com/public/bus/Getstop?stoptype=1&stopid=18&sid=3213f7d0fbf77de08fae3a2f2a2d4dec"

lhml_lxl(){

        station="老沪闵路罗秀路"
        curl -s -X POST "${to_url}" > /tmp/get_to.info
        get_to=$(cat /tmp/get_to.info)
        cat /tmp/get_to.info|grep "error" > /dev/null
        if [[ ${?} -eq 0 ]];then
            goto_inc=(${station})
        else
            num=`cat /tmp/get_to.info|awk -F ',' '{print $2}'|egrep -o "[A-B]-[0-9].*?[0-9]"`
            stopis=`cat /tmp/get_to.info|awk -F ',' '{print $3}'|sed 's/[^0-9]//g'`
            distance=`cat /tmp/get_to.info|awk -F ',' '{print $4}'|sed 's/[^0-9]//g'`
            time=`cat /tmp/get_to.info|awk -F ',' '{print $5}'|sed 's/[^0-9]//g'`
            min=$((${time}/60))
            sec=$((${time}%60))

            goto_inc=(${station} ${min} ${sec} ${num} ${distance} ${stopis})
        fi

        echo ${goto_inc[*]}
}

lhl_tll(){

        station="莲花路田林路"
        curl -s -X POST "${return_url}" > /tmp/get_return.info
        get_return=$(cat /tmp/get_return.info)
        cat /tmp/get_return.info|grep "error" > /dev/null
        if [[ ${?} -eq 0 ]];then
            return_home=(${station})
        else
            num=`cat /tmp/get_return.info|awk -F ',' '{print $2}'|egrep -o "[A-B]-[0-9].*?[0-9]"`
            stopis=`cat /tmp/get_return.info|awk -F ',' '{print $3}'|sed 's/[^0-9]//g'`
            distance=`cat /tmp/get_return.info|awk -F ',' '{print $4}'|sed 's/[^0-9]//g'`
            time=`cat /tmp/get_return.info|awk -F ',' '{print $5}'|sed 's/[^0-9]//g'`
            min=$((${time}/60))
            sec=$((${time}%60))

            return_home=(${station} ${min} ${sec} ${num} ${distance} ${stopis})
        fi

        echo ${return_home[*]}
}


send_to(){
    
    STATION=${1}
    MIN=${2}
    SEC=${3}
    NUM=${4}
    DISTANCE=${5}
    STOPIS=${6}

    if [[ ${#} -ne 1 ]]; then
        curl ${wxwork_hook} -H 'Content-Type: application/json' -d '
        {
            "msgtype": "markdown",
            "markdown": {
            "content": "> #### 867路公交车到达 '"${STATION}"' 还有：'"${MIN}"' 分 '"${SEC}"' 秒\n  > #### 车牌号是：沪'"${NUM}"'\n  > #### 距离 '"${DISTANCE}"' 米\n > #### 还有 '"${STOPIS}"' 站到达"
            }
        }'
    else
        curl ${wxwork_hook} -H 'Content-Type: application/json' -d '
        {
            "msgtype": "markdown",
            "markdown": {
            "content": "> #### '"${STATION}"'还没发车信息"
            }
        }'
    fi
}


option=${1}
case ${option} in
    goto)
        dataarray=$(lhml_lxl)
        send_to ${dataarray[*]}
    ;;
    return)
        dataarray=$(lhl_tll)
        send_to ${dataarray[*]}
    ;;
    *)
        echo "`basename ${0}`: usage: [goto] | [return]"
        exit 1 # Command to come out of the program with status 1
    ;;

esac
