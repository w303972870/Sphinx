#!/usr/bin/bash
set -e

DATA_DIR="/data/database/"
BUILD_INDEX_TYPE="--rotate"
BUILD_INDEX_NAME="--all"
IS_MERGE_INDEX=""

if [[ -z "$SKIP_INIT_INDEXER" ]] ;then

    if [ ! -z "$IS_FIRST_INDEXER" ] ;then
        if [ "$IS_FIRST_INDEXER" == "yes" ] ;then
            BUILD_INDEX_TYPE=""
        else
            BUILD_INDEX_TYPE="--rotate"
        fi
    fi
    
    if [[ ! -z "$BUILD_INDEX" ]] ;then
        BUILD_INDEX_NAME="$BUILD_INDEX"
    else
        BUILD_INDEX_NAME="--all"
    fi
    
    BUILD_INDEX_TYPE=""

    echo "开始执行：/usr/local/sphinx/bin/indexer --config /data/sphinx/etc/sphinx.conf  $BUILD_INDEX_NAME $BUILD_INDEX_TYPE"

    Build_Log=`/usr/local/sphinx/bin/indexer --config /data/sphinx/etc/sphinx.conf  $BUILD_INDEX_NAME $BUILD_INDEX_TYPE`
    echo $Build_Log

    if [[ ! -z "$MERGE" ]] ;then
        IS_MERGE_INDEX="--merge"
        echo "开始执行：/usr/local/sphinx/bin/indexer --config /data/sphinx/etc/sphinx.conf  $IS_MERGE_INDEX $MERGE"
        Build_Log=`/usr/local/sphinx/bin/indexer --config /data/sphinx/etc/sphinx.conf  $IS_MERGE_INDEX $MERGE`
        echo $Build_Log
    else
        IS_MERGE_INDEX=""
    fi
fi

exec "$@"