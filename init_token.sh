#!/bin/bash

export PROXY_PATHLENGTH=2
#export PROXY_POLICY=normal_policy
#export PROXY_STYLE=legacy_proxy
#export PATH=$PWD/etoken-pro/bin:$PATH
#export LD_LIBRARY_PATH=$PWD/etoken-pro/lib:$LD_LIBRARY_PATH
#export PKCS11_ENG=/usr/lib/i386-/etoken-pro/lib/engine_pkcs11.so
export PKCS11_MOD=/usr/lib/libeTPkcs11.so

zenity --info --text="введите PIN-код офицера безопасности"
SOPIN=$(zenity --password )
RET=$?
if [ "$SOPIN" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="вы не ввели PIN-код SO"
    exit 1
fi

#OUT=$(pkcs15-init --create-pkcs15 --so-pin "87654321" --so-puk "1122334455" --pin "$PIN" 2>/dev/stdout)
#RET=$?
#if [ "$OUT" == "" ] || [ "$RET" != "0" ]; then
#    zenity --error --text="$OUT"
#    exit 2
#fi

OUT=$(pkcs11-tool --module $PKCS11_MOD \
            --init-token --label "workvpn" --so-pin "$SOPIN" 2>/dev/stdout)
RET=$?
if [ "$OUT" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="init: $OUT"
    exit 2
fi
zenity --info --text="$OUT"

zenity --info --text="введите PIN-код пользователя"
PIN=$(zenity --password )
RET=$?
if [ "$PIN" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="вы не ввели PIN-код пользователя"
    exit 1
fi


OUT=$(pkcs11-tool --module $PKCS11_MOD \
            --login --login-type so --so-pin "$SOPIN" \
            --init-pin --new-pin "$PIN" 2>/dev/stdout)
RET=$?
if [ "$OUT" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="init-pin: $OUT"
    exit 2
fi
zenity --info --text="$OUT"


exit $RET
