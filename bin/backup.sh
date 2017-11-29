#!/usr/bin/env bash

BASEDIR="$(cd "$(dirname "$0")"/.. ; pwd)"

function instance_init () {
  export DBCFGInstance="$1"
  . <(cat ${BASEDIR}/${DBCFGInstance}/db.tematres.php  | grep -E -e '^\$DBCFG' | perl -p -e 's#( |\t|\r|^\$|\["|"\])##g; s#^#export #;')
}

function backup_tematres_instance () {
  instance_init "$1"
  year="$(date +"%Y")"
  month="$(date +"%m")"
  week="week$(($(($(date +"%d") / 7)) + 1))"
  yearmonthday="$(date +"%Y%m%d")"
  shorthostname="$(hostname -s)"
  backupfilename="${BASEDIR}/backups/${DBCFGInstance}/${year}/${month}/${week}/${DBCFGInstance}-${shorthostname}-${yearmonthday}.sql.gz"
  mkdir -p "$(dirname "${backupfilename}")"
  tables="$(echo "SHOW TABLES;" | mysql -u ${DBCFGDBLogin} -p${DBCFGDBPass} -h ${DBCFGServer} ${DBCFGDBName} | tail -n +2 | grep -E -e "^${DBCFGDBprefix}")"
  mysqldump -u ${DBCFGDBLogin} -p${DBCFGDBPass} -h ${DBCFGServer} ${DBCFGDBName} ${tables} | gzip > ${backupfilename}
}

function backup_tematres_instances () {
  while [ ! -z "$1" ] ; do {
    name="$1"
    shift 1
    backup_tematres_instance $name ;
  } ; done
}

backup_tematres_instances $*
