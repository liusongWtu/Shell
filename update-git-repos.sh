#!/bin/bash
REPO_DIR=~/Tools/Mac/
REPOS=(Shell) # 要定期更新资料库列表，用空格分隔
GIT_OPTS=("pull" "add -A" "commit -m'自动提交'" "push")
RETRY_INT=60
LOG_FILE=~/Documents/MyLog/.update_git.log

function fetch_git_reops {
    for r in "${REPOS[@]}"
    do
        echo "fetching... ${r}"
        cd $REPO_DIR/$r
        for i in "${GIT_OPTS[@]}"
        do
            git $i
        done
    done
}

if [ ! -t 1 ]; then
    exec 1>> $LOG_FILE 2>&1
fi
echo "Starting git repos update at `date`"
# check network connectivity
i=0
while :
do
    i=$((i + 1))
    QRES=`dig +time=5 +tries=1 +short github.com` ; QRET=$?
    if [ $QRET -eq 0 -a -n "$QRES" ]; then
        fetch_git_reops
        exit 0
    fi
    if [ $i -eq 5 ]; then
        echo "No network access. Giving up."
        exit 9
    fi
    echo "No network access. Retrying in $RETRY_INT seconds."
    sleep $RETRY_INT
done
