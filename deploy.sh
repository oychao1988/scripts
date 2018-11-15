#! /bin/bash
# 功能：自动化部署    
# 脚本名：Deploy.sh 
# 作者：TonyC  
# 版本：V 0.1   
# 联系方式：OYC_Tony@163.com

# 导入service脚本
source ./config.sh
source ./service.sh

# 日志记录
logger(){
    date=$(date +%F)
    time=$(date +%T)
    step="$1"
    status="$2"
    echo "${date} ${time} $0:${step} ${status}" >> "${DEPLOY_LOG_FILE}"
}

# 远程发送脚本
send_script(){
    logger "发送脚本 $1"
    echo "发送脚本 $1"
    scp "${SCRIPTS_PATH}/$1" "${REPERTORY_HOST}:${PROJECT_PATH}/$1" 
    if [ $? == 0 ]
    then
        echo "脚本 $1发送成功"
        logger "发送脚本 $1" "成功"
    else
        echo "脚本 $1发送失败"
        logger "发送脚本 $1" "失败"
    fi
}

# 远程删除脚本
delete_script(){
    logger "删除脚本 $1"
    ssh "${REPERTORY_HOST}" "bash ${PROJECT_PATH}/${CLEANUP_SCRIPT} ${PROJECT_PATH} $1"
    logger "删除脚本 $1" "成功"
}

# 1.获取代码
get_code(){
    logger "获取代码"
    echo "获取代码成功"
    logger "获取代码" "成功"
}
# 2.打包仓库代码
tar_code(){
    logger "打包仓库代码 ${REPERTORY_HOST}:${PROJECT_PATH}/$1"
    echo "向仓库发送打包代码指令"
    ssh "${REPERTORY_HOST}" "bash ${PROJECT_PATH}/${TAR_CODE_SCRIPT} ${PROJECT_PATH} $1"
    if [ $? == 0 ]
    then
        echo "打包仓库代码 $1 成功"
        logger "打包仓库代码 ${REPERTORY_HOST}:${PROJECT_PATH}/$1" "成功"
    else
        echo "打包仓库代码 $1 失败"
        logger "打包仓库代码 ${REPERTORY_HOST}:${PROJECT_PATH}/$1" "失败"
    fi
}
# 3.传输代码
scp_code(){
    logger "传输代码 ${REPERTORY_HOST}:${PROJECT_PATH}/$1"
    echo "开始传输代码 $1"
    if [ -f "${SCP_CODES_PATH}/$1" ]
    then
        rm -f "${SCP_CODES_PATH}/$1"
    fi
    scp "${REPERTORY_HOST}:${PROJECT_PATH}/$1.tar.gz" "${SCP_CODES_PATH}" >> "${DEPLOY_LOG_FILE}" 2>&1
    if [ $? == 0 ]
    then
        echo "传输代码 $1 成功"
        logger "传输代码 ${REPERTORY_HOST}:${PROJECT_PATH}/$1" "成功"
    else
        echo "传输代码 $1 失败"
        logger "传输代码 ${REPERTORY_HOST}:${PROJECT_PATH}/$1" "失败"
    fi
}
# 4.关闭服务
close_server(){
    logger "关闭服务"
    stop_server $1
    stop_nginx
    echo "关闭服务成功"
    logger "关闭服务" "成功"
}
# 5.备份代码
backup_code(){
    logger "备份旧代码 ${BACKUP_PATH}/$1-$(date +%Y%m%d%H%M%S).tar.gz"
    cd "${SERVER_PATH}"
    # 旧代码存在则备份
    if [ -d $1 ]     
    then
        tar -zvcf "${BACKUP_PATH}/$1-$(date +%Y%m%d%H%M%S).tar.gz" "$1" >> "${DEPLOY_LOG_FILE}" 2>&1
        if [ $? -eq 0 ]
        then
            echo "备份旧代码成功"
            logger "备份旧代码 ${BACKUP_PATH}/$1-$(date +%Y%m%d%H%M%S).tar.gz" "成功"
        else
            echo "备份旧代码失败"
            logger "备份旧代码 ${BACKUP_PATH}/$1-$(date +%Y%m%d%H%M%S).tar.gz" "失败"
        fi
    # 旧代码不存在则跳过
    else
        echo "备份旧代码失败 没有旧代码"
        logger "备份旧代码 ${BACKUP_PATH}/$1-$(date +%Y%m%d%H%M%S).tar.gz" "失败"
    fi
    cd "${BASE_DIR}"
}
# 6.解压代码
untar_code(){
    logger "解压代码"
    if [ -d "${SERVER_PATH}$1" ]
    then
        rm -r "${SERVER_PATH}$1"
    fi
    tar -zxf "${SCP_CODES_PATH}/$1.tar.gz" -C "${SERVER_PATH}" >> ${DEPLOY_LOG_FILE} 2>&1
    echo "解压代码成功"
    logger "解压代码" "成功"
}
# 7.开启服务
open_server(){
    logger "开启服务"
    start_nginx
    start_server $1
    echo "开启服务成功"
    logger "开启服务" "成功"
}
# 8.状态检测
status_check(){
    logger "状态检测"
    SERVER=$1
    PORT=$(eval echo '$'"${SERVER}_PORT")
    netstat -ntlp | grep "${PORT}" >> "${DEPLOY_LOG_FILE}" 2>&1
    echo "状态检测正常"
    logger "状态检测" "正常"
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

# 部署
deploy(){
    SERVER=$1
    add_lock
    logger "代码部署 ${SERVER}"
    echo
    echo "******代码部署 ${SERVER}********"
    get_code
    tar_code ${SERVER}
    scp_code ${SERVER}
    delete_script ${SERVER}
    close_server ${SERVER}
    backup_code ${SERVER}
    untar_code ${SERVER}
    open_server ${SERVER}
    status_check ${SERVER}
    echo "******代码部署成功 ${SERVER}******"
    echo
    logger "代码部署 ${SERVER}" "成功"
    del_lock
}

# 提示信息
tip_msg(){
    echo "脚本 $0 正在运行，请稍候"
}

# 脚本帮助信息
useage(){
    echo "自动化部署脚本 $0 使用方法："
    echo "bash $0 deploy [all|1|2|3|4|5]"
    echo "请选择要部署的服务："
    echo "all:所有"
    echo "1:${SERVER_LIST[1]}"
    echo "2:${SERVER_LIST[2]}"
    echo "3:${SERVER_LIST[3]}"
    echo "4:${SERVER_LIST[4]}"
    echo "5:${SERVER_LIST[5]}"
    exit
}

# 主程序入口
main(){
    # 选项
    case $1 in
        "deploy")
            if [ -f "${LOCK_FILE}" ]
            then
                tip_msg
            else
                echo "即将发送打包脚本${TAR_CODE_SCRIPT}"
                if [ "$2" == "all" ]
                then
                    # 发送打包脚本
                    send_script "${TAR_CODE_SCRIPT}"
                    send_script "${CLEANUP_SCRIPT}"
                    for service in ${SERVER_LIST[*]}
                    do
                        deploy "${service}" 
                    done
                    delete_script "all"
                elif [ "$2" == "1" ] || [ "$2" == "2" ] || [ "$2" == "3" ] || [ "$2" == "4" ] || [ "$2" == "5" ]
                then
                    # 发送打包脚本
                    send_script "${TAR_CODE_SCRIPT}"
                    send_script "${CLEANUP_SCRIPT}"
                    deploy "${SERVER_LIST[$2]}"
                    delete_script "all"
                else
                    useage
                fi  
            fi
            ;;
        *)
            useage
            ;;
    esac
}

# 参数数量控制
if [ $# -eq 2 ]
then
    main $1 $2
else
    useage
    exit
fi
