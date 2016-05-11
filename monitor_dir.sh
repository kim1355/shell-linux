#/bin/bash

# 监控路径
DIR=/root/bin

# 查询结果
Check_1=/root/check_1.txt
Check_2=/root/check_2.txt

# 日志文件
Log_F=/root/monitor.log

# 系统时间
Date=`date +%F--%H:%M:%S`

function init()
{
        echo "${Date}--文件初始状态：" >> ${Log_F}
        find ${DIR} -print0 | xargs -0 du -sb  > ${Check_1}
        echo "${Date}--文件初始化完成--" >> ${Log_F}
        echo
}


function monitor()
{
        echo "${Date}--开始监控文件夹${DIR}--" >> ${Log_F}
        echo "-------------------------------" >> ${Log_F}
        echo 
        find ${DIR} -print0 | xargs -0 du -sb  > ${Check_2}

        MD5_1=`md5sum ${Check_1}`
        MD5_2=`md5sum ${Check_2}`
        # 对比查询文件夹结果
        echo "${MD5_1}"
        echo "${MD5_2}"

        if [[ ${MD5_1} -eq ${MD5_2} ]]
        then
                echo "${Date}--文件夹${DIR}}没有变化！" >> ${Log_F}

        else
                echo "${Date}--注意啦--文件夹${DIR}有变化了！！！！！" >> ${Log_F}
                echo "" >> ${Log_F}
                echo "${Date}--可以触发工作任务啦--" >> ${Log_F}
           
                init
                   
        fi
        echo "====================================" >> ${Log_F}
        #rm -f ${Check_2}
}


function main()
{
        init

        while (true)
        do
                monitor
                # 3秒监控一次
                sleep 3
        done
}

# 执行主函数

main
