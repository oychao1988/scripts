SERVER=$1
PORT=$2
SERVER_PATH="/home/python/Documents/Project/server"
VIRTUAL_PATH="/home/python/Documents/Project/virtual"

# 进入项目执行路径
cd "${SERVER_PATH}/${SERVER}"
# 进入虚拟环境
source "${VIRTUAL_PATH}/${SERVER}/bin/activate"
# gunicorn启动项目
gunicorn -w 2 -b 127.0.0.1:"${PORT}" manage:app
