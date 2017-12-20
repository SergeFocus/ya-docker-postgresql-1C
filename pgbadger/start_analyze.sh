REPORT_DIR=/var/www/html/
PARALLEL_PROC=4
PGBADGER_TZ=+03
LOG_DIR=/var/log/pg-logs
PARCED_LOG_DIR=${LOG_DIR}/analyzed

cd ${LOG_DIR}

if [[ ! -d ${REPORT_DIR} ]]; then
    echo create report dir in ${REPORT_DIR}
    mkdir -p ${REPORT_DIR}
    else
    echo ${REPORT_DIR} already exist
fi

if [[ ! -d ${PARCED_LOG_DIR} ]]; then
    echo create archive log dir in ${PARCED_LOG_DIR}
    mkdir -p ${PARCED_LOG_DIR}
    else
    echo ${PARCED_LOG_DIR} already exist
fi


file=`ls -1rt *.log.gz | head -1`
pgbadger -I -q -J ${PARALLEL_PROC} --start-monday -Z ${PGBADGER_TZ} $file \
    -O ${REPORT_DIR} && \
    mv $file ${PARCED_LOG_DIR}/$file
