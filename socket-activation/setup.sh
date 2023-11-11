#!/usr/bin/env bash

#Define paths to use
SERVICE_PATH=$(git rev-parse --show-toplevel 2>/dev/null)
SA_PATH=${SERVICE_PATH}/socket-activation
USER_SYSTEMD_PATH=${HOME}/.config/systemd/user


. ${SERVICE_PATH}/.env

# Regular expressions definitions
REGEXP_SERVICE_PATH="s!SERVICE_PATH!${SERVICE_PATH}!g"
REGEXP_GLOBAL_IP="s/GLOBAL_IP/${GLOBAL_IP}/g"
REGEXP_GLOBAL_PORT="s/GLOBAL_PORT/${GLOBAL_PORT}/g"
REGEXP_SERVICE="s/EXAMPLE/$1/g"
REPLACE_PORT=PORT_${1}
REGEXP_SERVICE_PORT="s/${REPLACE_PORT}/${!REPLACE_PORT}/g"

mkdir -p ${USER_SYSTEMD_PATH}
cd ${SA_PATH}
for template in $(ls templates); do
    SYSTEM_UNIT=$(echo ${template} | sed ${REGEXP_SERVICE})
    cp -f templates/${template} ${USER_SYSTEMD_PATH}/${SYSTEM_UNIT}
    sed -i ${REGEXP_SERVICE} ${USER_SYSTEMD_PATH}/${SYSTEM_UNIT}
    sed -i ${REGEXP_GLOBAL_IP} ${USER_SYSTEMD_PATH}/${SYSTEM_UNIT}
    sed -i ${REGEXP_GLOBAL_PORT} ${USER_SYSTEMD_PATH}/${SYSTEM_UNIT}
    if [[ $template == *"socket" ]]; then
        sed -i ${REGEXP_SERVICE_PORT} ${USER_SYSTEMD_PATH}/${SYSTEM_UNIT}
        systemctl --user enable --now $SYSTEM_UNIT
    fi
    sed -i ${REGEXP_SERVICE_PATH} ${USER_SYSTEMD_PATH}/${SYSTEM_UNIT}
done

if [[ -f ${USER_SYSTEMD_PATH}/$1.socket ]]; then
    systemctl --user daemon-reload
    echo "Socket activation for $1 done"
else
    echo "There was an error, please debug it ;)"
    echo "... or report it"
fi
