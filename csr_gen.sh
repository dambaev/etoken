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
if [ "$LABEL" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="ввод отклонен"
    exit 4
fi

OUT=$(openssl req -engine pkcs11 -keyform engine -key 12346578 \
    -new -out client.req \
    -subj "/S=buryatia/O=baikalbank/CN=$USER" 2>/dev/stdout)
RET=$?
if [ "$OUT" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="openssl-req: $OUT"
    exit 5
fi
zenity --info --text="$OUT"

exit $RET
