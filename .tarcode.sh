#! /bin/bash

FILE_PATH=$1
FILE_NAME=$2
echo "仓库代码 ${FILE_NAME} 开始打包"
cd "${FILE_PATH}"
if [ -f "${FILE_NAME}.tar.gz" ]
then
    rm -f "${FILE_NAME}.tar.gz"
fi
tar -zcf "${FILE_NAME}".tar.gz "${FILE_NAME}"
# if [ $? == 0 ]
# then
#     echo "打包仓库代码 ${FILE_NAME} 成功"
# else
#     echo "打包仓库代码 ${FILE_NAME} 失败"
# fi
