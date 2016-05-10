#! /bin/bash

#---------DGPOS维护脚本
#---------版本：v1.0
#---------作者：Wuzq
#---------创建时间：2016-05-09



# ---------定义相关变量---------

# 程序备份路径
backup_dir=/home/dgpos/app_backup/

# 升级包路径
update_dir=/home/dgpos/app_update/

# 程序部署路径
app_dir=/home/dgpos/EBS_SERVER/lib/

# 运行脚本路径
app_bin=/home/dgpos/EBS_SERVER

# 系统时间
date=`date +%Y%m%d%H%M`
date_1=`date +"%Y-%m-%d %H:%M:%S"`

# 程序包名称
file_name=ebs-server.jar



# ---------定义相关功能模块---------
function display() {
cat <<EOF
                                1.查看DGPOS程序进程和监听端口状态

                                2.启动DGPOS进程服务

                                3.停止DGPOS进程服务

                                4.智能更新ebs-server.jar程序包

                                5.恢复ebs-server.jar版本

                                0.退出

请输入需要操作的选项(0-5)：
EOF
read num

expr $num + 10 1>/dev/null 2>&1
if [ $? -eq 0 ];then
        if (( num <= 5 )) && (( num >= 0 ))
        then
#               echo "--继续执行下一步--"
                echo
                case $num in
                        0)
                                return 0
                        ;;
                        1)
                                return 1
                        ;;
                        2)
                                return 2
                        ;;
                        3)
                                return 3
                        ;;
                        4)
                                return 4
                        ;;
                        5)
                                return 5
                        ;;
                esac
        else
                echo "输入字符错误，请重新输入！"
                display
        fi
else
        echo "输入字符错误，请重新输入！"
        display
fi
}



function check_app()
{
        echo "-----应用程序进程状态------"
        ps -ef|grep main.spring.StartServer|grep -v grep
        echo 
        echo "-----监听端口状态-----"
        netstat -tunlp|grep 21
        choice
}

function stop_app()
{
        P_num=`ps -ef|grep main.spring.StartServer|grep -v grep|wc -l`
        while [[ ${P_num} -ne 0 ]]
                do
                ps -ef|grep main.spring.StartServer |grep -v grep| awk '{ print "kill -9 " $2 }' | xargs -iP kill -9 P
                sleep 2
                done
        echo "--DGPOS应用程序已经成功停止!"
        choice
}

function start_app()
{
        nohup /home/dgpos/EBS_SERVER/EBS_START.sh &
        sleep 3
        P_num_1=`ps -ef|grep main.spring.StartServer|grep -v grep|wc -l`
        if [[ ${P_num_1} == 0 ]];then
                echo "--DGPOS应用程序启动失败！"
        else
                echo "--DGPOS应用程序启动正常！"
        fi
        choice
}

function backup()
{

        if [[ -f  ${app_dir}${file_name} ]];then
                echo "--开始备份程序包：${app_dir}${file_name}!"
                cp ${app_dir}${file_name} ${backup_dir}${file_name}-${date}
                echo "-----------------------------------------------------"
                sleep 5
                if [[ -f ${backup_dir}${file_name}-${date} ]];then
                        echo "-----------------------------------------------------"
                        echo "--${app_dir}${file_name}已备份为${backup_dir}${file_name}-${date}！"
                        echo "-----------------------------------------------------"
                        return 0
                else
                        echo "-----------------------------------------------------"
                        echo "--${app_dir}${file_name}备份失败！"
                        echo "-----------------------------------------------------"
                        return -1
                fi
        else
                echo "-----------------------------------------------------"
                echo "--程序包${app_dir}${file_name}不存在！不能进行备份！！！"
                echo "-----------------------------------------------------"
                                return -2
        fi
}

function update()
{
        if [[ -f ${update_dir}${file_name} ]];then

        backup

        if [[ $? -eq 0 ]];then

                                echo "开始停止DGPOS应用程序！"
                                echo "-----------------------------------------------------"
                                P_num=`ps -ef|grep main.spring.StartServer|grep -v grep|wc -l`
                                while [[ $P_num -ne 0 ]]
                                                do
                                                ps -ef|grep main.spring.StartServer |grep -v grep| awk '{ print "kill -9 " $2 }' | xargs -iP kill -9 P
                                                sleep 3
                                                done
                                echo "DGPOS应用程序已经成功停止!"
                                echo "-----------------------------------------------------"


                echo "开始更新DGPOS应用程序包${update_dir}${file_name}!"
                echo "-----------------------------------------------------"

                                echo "准备更新替换${update_dir}${file_name}！"
                                echo "-----------------------------------------------------"
                                mv ${update_dir}${file_name} ${app_dir}
                                sleep 5

                                if [[ -f ${app_dir}${file_name} ]];then
                                                echo "程序包${update_dir}${file_name}已完成更新替换！"
                                                echo "-----------------------------------------------------"
                                                echo "开始启动DGPOS程序服务！"
                                                echo "-----------------------------------------------------"
                                                nohup /home/dgpos/EBS_SERVER/EBS_START.sh &
                                                sleep 3
                                                P_num_1=`ps -ef|grep main.spring.StartServer|grep -v grep|wc -l`

                                                if [[ ${P_num_1} == 0 ]];then
                                                                echo "-----------------------------------------------------"
                                                                echo "DGPOS应用程序启动失败！"
                                                                echo "-----------------------------------------------------"
                                                else
                                                                echo "-----------------------------------------------------"
                                                                echo "DGPOS应用程序启动正常！"
                                                                echo "-----------------------------------------------------"
                                                fi
                                else
                                                echo "-----------------------------------------------------"
                                                echo "程序包${app_dir}${file_name}替换失败!"
                                                echo "-----------------------------------------------------"
                                fi

                        else
                                echo "备份操作为成功！！！！"
                        fi
        else
                echo "-----------------------------------------------------"
                echo "更新文件${update_dir}${file_name}不存在！"
                echo "-----------------------------------------------------"

        fi
        choice
}


rollback()
{

        # 选择备份文件
        roll_file=`ls -ltr ${backup_dir} |awk '{print $8}'`
        if [[ ! -z ${roll_file} ]];then

                echo "--可选择的恢复版本如下："
                for i in ${roll_file}
                do
                        echo ${i}
                done
        else
                echo "${backup_dir}路径下没有可恢复的版本！！！"
                choice
        fi

        read -p "--请选择恢复版本文件：" F
        echo "----------已选择的备份文件为：${backup_dir}${F}-------------------"
        echo "-----------------------------------------------------"

                echo "--开始恢复DGPOS应用程序包${backup_dir}${F}!"
                echo "-----------------------------------------------------"

                if [[ -f ${backup_dir}${F} ]];then

                                backup

                                echo "--当前版本${app_dir}${file_name}已完成备份！！！"

                                sleep 3

                                rm -f ${app_dir}${file_name}

                                sleep 3

                                if [[ $? -eq 0 ]];then

                                        echo "--当前版本${app_dir}${file_name}已删除！！！"
                                        echo
                                        echo "开始停止DGPOS应用程序！"
                                        echo "-----------------------------------------------------"
                                        P_num=`ps -ef|grep main.spring.StartServer|grep -v grep|wc -l`
                                        while [[ $P_num -ne 0 ]]
                                        do
                                                ps -ef|grep main.spring.StartServer |grep -v grep| awk '{ print "kill -9 " $2 }' | xargs -iP kill -9 P
                                                sleep 3
                                        done
                                        echo "DGPOS应用程序已经成功停止!"
                                        echo "-----------------------------------------------------"

                                        echo "准备恢复备份文件${backup_dir}${F}！"
                                        echo "-----------------------------------------------------"
                                        cp ${backup_dir}${F} ${app_dir}${file_name}
                                        sleep 5

                                        if [[ -f ${app_dir}${file_name} ]];then
                                                        echo "程序包${backup_dir}${F}已完成恢复替换！"
                                                        echo "-----------------------------------------------------"
                                                        echo "开始启动DGPOS程序服务！"
                                                        echo "-----------------------------------------------------"
                                                        nohup /home/dgpos/EBS_SERVER/EBS_START.sh &
                                                        sleep 3
                                                        P_num_1=`ps -ef|grep main.spring.StartServer|grep -v grep|wc -l`

                                                        if [[ ${P_num_1} == 0 ]];then
                                                                        echo "-----------------------------------------------------"
                                                                        echo "DGPOS应用程序启动失败！"
                                                                        echo "-----------------------------------------------------"
                                                        else
                                                                        echo "-----------------------------------------------------"
                                                                        echo "DGPOS应用程序启动正常！"
                                                                        echo "-----------------------------------------------------"
                                                        fi
                                        else
                                                        echo "-----------------------------------------------------"
                                                        echo "程序包${backup_dir}${F}替换失败!"
                                                        echo "-----------------------------------------------------"
                                        fi

                                else
                                                echo "备份失败了啊！"

                                fi
                else
                                echo "-----------------------------------------------------"
                                echo "恢复文件${backup_dir}${F}不存在！"
                                echo "-----------------------------------------------------"
                fi

        choice
}


choice()
{
  echo
  echo "--输入'Q'或'q'返回主界面，或同时按下CTRL+C键退出本次操作--"
  read ch
  if [[ ${ch} == "Q" ]] || [[ ${ch} == "q" ]]
  then
  echo "--进入主界面--"  
  echo "--当前时间：${date_1}"
  echo
  display
  main
  else
  echo "输入字符错误，请重新输入！"
  choice
  fi
}


function main()
{
case $? in
        0)
                exit 0
        ;;
        1)
                check_app
        ;;
        2)
                start_app
        ;;
        3)
                stop_app
        ;;
        4)
                update
        ;;
        5)
                rollback
        ;;
        esac

}


# 程序开始--标题
echo "==============================================================================="
echo "                                  欢迎使用DGPOS维护脚本                        "
echo "                               版本：v1.0                                      "
echo "                               作者：Wuzq                                      "
echo "                           当前时间：${date_1}                                 "
echo "==============================================================================="
echo

display
main
