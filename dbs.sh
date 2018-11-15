#! /bin/bash
# 功能：数据库开启    
# 脚本名：start_dbs.sh
# 作者：TonyC  
# 版本：V 0.1   
# 联系方式：OYC_Tony@163.com


source ./config.sh

# 日志记录
logger(){
    date=$(date +%F)
    time=$(date +%T)
    step="$1"
    status="$2"
    echo "${date} ${time} $0:${step} ${status}" >> "${START_DBS_LOG_FILE}"
}

# 开启mysql数据库
start_mysql(){
    logger "启动mysql数据库"
    sudo service mysql start
    if [ $? == 0 ]
    then
        echo "mysql数据库已启动"
        logger "启动mysql数据库" "成功"
    else
        echo "mysql数据库启动失败"
        logger "启动mysql数据库" "失败"
    fi
}

# 关闭mysql数据库
stop_mysql(){
    logger "关闭mysql数据库"
    sudo service mysql stop
    if [ $? == 0 ]
    then
        echo "mysql数据库已关闭"
        logger "关闭mysql数据库" "成功"
    else
        echo "mysql数据库关闭失败"
        logger "关闭mysql数据库" "失败"
    fi
}

# 开启redis数据库
start_redis(){
    logger "启动redis数据库"
    redis-server &
    if [ $? == 0 ]
    then
        echo "redis数据库已启动"
        logger "启动redis数据库" "成功"
    else
        echo "redis数据库启动失败"
        logger "启动redis数据库" "失败"
    fi
}

# 关闭redis数据库
stop_redis(){
    logger "关闭redis数据库"
    redis-cli shutdown
    if [ $? == 0 ]
    then
        echo "redis数据库已关闭"
        logger "关闭redis数据库" "成功"
    else
        echo "redis数据库关闭失败"
        logger "关闭redis数据库" "失败"
    fi
}

# 开启mongodb数据库
start_mongodb(){
    logger "启动mongodb数据库"
    sudo mongod --smallfiles --fork --logpath="${MONGODB_LOG_FILE}"
    if [ $? == 0 ]
    then
        echo "mongodb数据库已启动"
        logger "启动mongodb数据库" "成功"
    else
        echo "mongodb数据库启动失败"
        logger "启动mongodb数据库" "失败"
    fi
}

# 关闭mongodb数据库
stop_mongodb(){
    logger "关闭mongodb数据库"
    mongo admin --eval "db.shutdownServer()"
    if [ $? == 0 ]
    then
        echo "mongodb数据库已关闭"
        logger "关闭mongodb数据库" "成功"
    else
        echo "mongodb数据库关闭失败"
        logger "关闭mongodb数据库" "失败"
    fi
}

# 添加锁文件
add_lock(){
    touch "${LOCK_FILE}"
    logger "添加锁文件"    
}

# 删除锁文件
del_lock(){
    rm -rf "${LOCK_FILE}"
    logger "删除锁文件"
}

# 提示信息
tip_msg(){
    echo "脚本 $0 正在运行，请稍候"
}

# 脚本帮助信息
useage(){
    echo "数据库开启脚本 $0 使用方法："
    echo "bash $0 [start|stop] [all|1|2|3]"
    echo "请选择要开启|关闭的数据库："
    echo "all:所有"
    echo "1:${DB_LIST[1]}"
    echo "2:${DB_LIST[2]}"
    echo "3:${DB_LIST[3]}"
    exit
}

# 主程序入口
main(){
    if [ -f "${LOCK_FILE}" ]
    then
        tip_msg
        exit
    fi
    # 选项
    if [ "$1" == "start" ] || [ "$1" == "stop" ]
    then
        echo "正在$1数据库"
    else
        useage
        exit
    fi
    add_lock
    #　开启｜关闭所有数据库
    if [ "$2" == "all" ]
    then
        for db in ${DB_LIST[*]}
        do
            "$1_${db}"
        done
    #　开启｜关闭单个数据库
    elif [ "$2" == "1"  ] || [ "$2" == "2"  ] || [ "$2" == "3"  ]
    then
        "$1_${DB_LIST[$2]}"
    else
        del_lock
        useage
    fi
    del_lock    
}

# 参数数量控制
if [ $# -eq 2 ]
then
    main $1 $2
else
    useage
fi
