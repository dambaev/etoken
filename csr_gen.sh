#!/bin/bash

export PROXY_PATHLENGTH=2
#export PROXY_POLICY=normal_policy
#export PROXY_STYLE=legacy_proxy
#export PATH=$PWD/etoken-pro/bin:$PATH
#export LD_LIBRARY_PATH=$PWD/etoken-pro/lib:$LD_LIBRARY_PATH
#export PKCS11_ENG=/usr/lib/i386-/etoken-pro/lib/engine_pkcs11.so
export PKCS11_MOD=/usr/lib/libeTPkcs11.so

LABEL=$(zenity --entry --text="Введите email пользователя")
RET=$?
if [ "$LABEL" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="ввод отклонен"
    exit 1
fi

zenity --info --text="Введите PIN пользователя"

PIN=$(zenity --password )
RET=$?
if [ "$PIN" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="вы не ввели PIN-код"
    exit 2
fi

OUT=$(pkcs11-tool --module $PKCS11_MOD \
               --keypairgen --key-type rsa:2048  \
               --login \
               --pin "$PIN" \
               --label "$LABEL" --id 12345678 2>/dev/stdout)
RET=$?
if [ "$OUT" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="generatepair: $OUT"
    exit 3
fi
zenity --info --text="$OUT"

USER=$(zenity --entry --text="ФИО пользователя" )
RET=$?
if [ "$USER" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="ввод отклонен"
    exit 4
fi

zenity --info --text="Выберите имя для запроса"

CSR=$(zenity --file-selection --confirm-overwrite \
    --file-filter="*.req" --filename "client.req" --save)
RET=$?
if [ "$CSR" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="ввод отклонен"
    exit 4
fi


TMP=$(mktemp --suffix=.cnf)

echo "
openssl_conf = openssl_def

[openssl_def]
engines = engine_section

[engine_section]
pkcs11 = pkcs11_section

[pkcs11_section]
engine_id = pkcs11
dynamic_path = /usr/lib/engines/engine_pkcs11.so
MODULE_PATH = /usr/lib/libeToken.so
init = 0


[ req ]
default_bits           = 2048
distinguished_name     = req_distinguished_name
prompt                 = no

[ req_distinguished_name ]
C                      = RU
ST                     = buryatia
L                      = ulan-ude
O                      = baikalbank
CN                     = $USER
emailAddress           = $LABEL
" > $TMP

OUT=$(echo $PIN | (openssl req -config $TMP -engine pkcs11 -keyform engine \
    -key 12345678 -new -out "$CSR" \
    -passin stdin \
    -subj "/C=RU/ST=buryatia/L=ulan-ude/O=baikalbank/CN=$USER" 2>/dev/stdout))
RET=$?
if [ "$OUT" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="openssl-req: $OUT"
    exit 5
fi
zenity --info --text="$OUT"

exit $RET
