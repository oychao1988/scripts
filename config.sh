# 代码仓库参数配置
PROJECT_PATH="/home/python/Documents/MainProject"
REPERTORY_HOST="python@192.168.223.129" 

# 可以部署的服务列表
SERVER_LIST=([1]=ScheduleServer 
             [2]=MongoDBDataServer 
             [3]=DataMiningServer 
             [4]=SpiderServer 
             [5]=WebServer
             [6]=ProxyPoolServer)


# 可部署的数据库列表
DB_LIST=([1]=mysql 
         [2]=redis
         [3]=mongodb
)

# 服务器端口配置
WebServer_PORT=5001
ProxyPoolServer=5011
MongoDBDataServer_PORT=5021
DataMiningServer_PORT=5031
SpiderServer_PORT=5041
ScheduleServer_PORT=5051

# 服务器路径配置
BASE_DIR="/home/python/Documents/Project"
SCRIPTS_PATH="${BASE_DIR}/scripts"
LOCK_FILE="${SCRIPTS_PATH}/.$0.lock"
SCP_CODES_PATH="${BASE_DIR}/scp_codes"
SERVER_PATH="${BASE_DIR}/server"
BACKUP_PATH="${BASE_DIR}/backup"
VIRTUAL_PATH="${BASE_DIR}/virtual"
LOG_PATH="${BASE_DIR}/logs"
DEPLOY_LOG_FILE="${LOG_PATH}/deploy.log"
START_DBS_LOG_FILE="${LOG_PATH}/start_dbs.log"
MONGODB_LOG_FILE="${LOG_PATH}/mongodb.log"

# 发送的远程打包代码
TAR_CODE_SCRIPT=".tarcode.sh"
CLEANUP_SCRIPT=".cleanup.sh"