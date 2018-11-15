#! /bin/bash


main(){
    FILE_PATH=$1
    FILE_NAME=$2
    cd "${FILE_PATH}"
    if [ $2 == 'all' ]
    then
        echo "删除 .tarcode.sh"
        rm -f .tarcode.sh
        echo "删除 .cleanup.sh"
        rm -f .cleanup.sh
    else
        echo "删除 ${FILE_NAME}.tar.gz"
        rm -f "${FILE_NAME}".tar.gz
    fi
}

main $1 $2
