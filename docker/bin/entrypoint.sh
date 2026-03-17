#!/bin/bash

set -ex

readonly DFT_LOGGING_FLR="/var/log/librebooking"
readonly DFT_LOGGING_LEVEL="INFO"
readonly DFT_LOGGING_SQL=false

file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  local varValue
  varValue=$(env | grep -E "^${var}=" | sed -E -e "s/^${var}=//")
  local fileVarValue
  fileVarValue=$(env | grep -E "^${fileVar}=" | sed -E -e "s/^${fileVar}=//")
  if [ -n "${varValue}" ] && [ -n "${fileVarValue}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  if [ -n "${varValue}" ]; then
    export "$var"="${varValue}"
  elif [ -n "${fileVarValue}" ]; then
    export "$var"="$(cat "${fileVarValue}")"
  elif [ -n "${def}" ]; then
    export "$var"="$def"
  fi
  unset "$fileVar"
}

file_env LB_INSTALL_PASSWORD
file_env LB_DATABASE_PASSWORD

LB_LOGGING_FOLDER=${LB_LOGGING_FOLDER:-${DFT_LOGGING_FLR}}
LB_LOGGING_LEVEL=${LB_LOGGING_LEVEL:-${DFT_LOGGING_LEVEL}}
LB_LOGGING_SQL=${LB_LOGGING_SQL:-${DFT_LOGGING_SQL}}

if ! [ -f /config/config.php ]; then
  echo "Initialize file config.php"
  cp /var/www/html/config/config.dist.php /config/config.php
fi

if ! [ -L /var/www/html/config/config.php ]; then
  rm -f /var/www/html/config/config.php
  ln -s /config/config.php /var/www/html/config/config.php
fi

while IFS= read -r -d '' source; do
  target=${source//.dist/}
  if ! [ -f "/config/$(basename "${target}")" ]; then
    cp --no-clobber "${source}" "/config/$(basename "${target}")"
  fi
  if ! [ -e "${target}" ]; then
    ln -s "/config/$(basename "${target}")" "${target}"
  fi
done < <(find /var/www/html/plugins -type f -name "*dist*" -print0)

if [ -f /usr/share/zoneinfo/"${LB_DEFAULT_TIMEZONE}" ]; then
  INI_FILE="/usr/local/etc/php/conf.d/librebooking.ini"
  echo "[Date]" >"${INI_FILE}"
  echo "date.timezone=\"${LB_DEFAULT_TIMEZONE}\"" >>"${INI_FILE}"
fi

mkdir -p "${LB_LOGGING_FOLDER}"
touch "${LB_LOGGING_FOLDER}/app.log" "${LB_LOGGING_FOLDER}/sql.log"
tail --follow "${LB_LOGGING_FOLDER}/app.log" >>/dev/stdout &
tail --follow "${LB_LOGGING_FOLDER}/sql.log" >>/dev/stdout &

exec "$@"
