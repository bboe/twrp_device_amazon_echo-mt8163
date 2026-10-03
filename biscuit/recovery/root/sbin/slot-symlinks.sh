#!/sbin/sh

PATH=/sbin:/system/sbin:/system/bin:/system/xbin
BYNAME=/dev/block/platform/bootdevice/by-name
SCRATCH=/tmp/ota-decoy

SLOT=$(getprop ro.boot.slot_suffix 2>/dev/null)
if [ -z "$SLOT" ]; then
    SLOT="_a"
    /sbin/resetprop ro.boot.slot_suffix "$SLOT" > /dev/null 2>&1
fi

# amonet v1.1.0 keeps its own image in boot_a and boot_b, and Fire OS
# boots from boot_a_x and boot_b_x. Point the boot names at Fire OS's, as
# v1.1.0's TWRP does, so nothing here can overwrite amonet's.
for s in _a _b; do
    real=$(readlink -f ${BYNAME}/boot${s}_x)
    amonet=$(readlink -f ${BYNAME}/boot${s})
    if [ -b "$real" ] && [ -b "$amonet" ] && [ "$real" != "$amonet" ]; then
        rm -f ${BYNAME}/boot${s}
        ln -s "$real" ${BYNAME}/boot${s}
        ln -sf "$amonet" ${BYNAME}/boot${s}_amonet
    fi
done

ln -sf "$(readlink -f ${BYNAME}/boot${SLOT})"   /dev/block/current-boot
ln -sf "$(readlink -f ${BYNAME}/system${SLOT})" /dev/block/current-system

DECOYS="lk_a:1048576 lk_b:1048576 tee1:5242880 tee2:5242880 tee:5242880 preloader:4194304"

mkdir -p ${SCRATCH}

for decoy in ${DECOYS}; do
    part=${decoy%:*}
    size=${decoy#*:}

    if [ -b "${BYNAME}/${part}" ]; then
        real=$(readlink -f ${BYNAME}/${part})
        [ -n "$real" ] && ln -sf "$real" ${BYNAME}/${part}_real
    fi

    dd if=/dev/zero of=${SCRATCH}/${part} bs=1 count=1 seek=$((size - 1)) > /dev/null 2>&1

    rm -f ${BYNAME}/${part}
    ln -s ${SCRATCH}/${part} ${BYNAME}/${part}
done
