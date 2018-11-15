#! /bin/bash


# 开启服务器
start_server(){
    SERVER=$1
    echo "开启服务"
    logger "开启服务 ${SERVER}"
    PORT=$(eval echo '$'"${SERVER}_PORT")
    if [ ! -d "${VIRTUAL_PATH}/${SERVER}" ]
    then
        cd "${VIRTUAL_PATH}"
        create_virtualenv ${SERVER}
    fi
    cd "${SCRIPTS_PATH}"
    # screen启动服务
    screen -dmS "${SERVER}" bash gunicorn.sh "${SERVER}" "${PORT}"
    echo "开启服务成功"
    logger "开启服务 ${SERVER}" "成功"
}

# 关闭服务器
stop_server(){
    SERVER=$1
    logger "关闭服务 ${SERVER}"
    echo "关闭服务"
    PORT=$(eval echo '$'"${SERVER}_PORT")
    kill -9 $(lsof -i:"${PORT}") >> "${DEPLOY_LOG_FILE}" 2>&1
    echo "关闭服务成功"
    logger "关闭服务 ${SERVER}" "成功"
}

# 开启nginx
start_nginx(){
    echo "开启nginx"
}

# 关闭nginx
stop_nginx(){
    echo "关闭nginx"
}

# 创建虚拟环境
create_virtualenv(){
    SERVER=$1
    logger "创建虚拟环境 ${SERVER}"
    echo "创建虚拟环境"
    # 进入虚拟环境项目路径
    cd "${VIRTUAL_PATH}" 
    virtualenv -p python3 "${SERVER}" >> "${DEPLOY_LOG_FILE}" 2>&1
    source "${VIRTUAL_PATH}/${SERVER}/bin/activate" 
    echo "准备安装依赖包"
    pip install -r "${SERVER_PATH}/${SERVER}/requirements.txt" >> "${DEPLOY_LOG_FILE}" 2>&1
    deactivate
    echo "创建虚拟环境 ${SERVER} 成功"
    logger "创建虚拟环境 ${SERVER}" "成功"
    cd "${SCRIPTS_PATH}"
}
