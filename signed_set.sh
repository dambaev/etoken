#!/bin/bash

export PROXY_PATHLENGTH=2
export PKCS11_MOD=/usr/lib/libeTPkcs11.so

zenity --info --text="Выберите сертификат, подписанный CA"

CERT=$(zenity --file-selection)
RET=$?
if [ "$CERT" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="ввод отклонен"
    exit 1
fi


LABEL=$(zenity --entry --text="Введите email пользователя")
RET=$?
if [ "$LABEL" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="ввод отклонен"
    exit 2
fi

zenity --info --text="Введите PIN пользователя"

PIN=$(zenity --password )
RET=$?
if [ "$PIN" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="вы не ввели PIN-код"
    exit 3
fi

OUT=$(pkcs11-tool --module $PKCS11_MOD \
               -w "$CERT" --type cert  \
               --login \
               --pin "$PIN" \
               --label "$LABEL" --id 12345678 2>/dev/stdout)
RET=$?
if [ "$OUT" == "" ] || [ "$RET" != "0" ]; then
    zenity --error --text="write cert: $OUT"
    exit 4
fi
zenity --info --text="$OUT"

