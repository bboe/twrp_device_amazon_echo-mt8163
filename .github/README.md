# TWRP for a v1-unlocked Echo Dot (2nd Gen)

A fork of [R0rt1z2's TWRP tree for MT8163 Echo devices](https://github.com/R0rt1z2/twrp_device_amazon_echo-mt8163) whose `biscuit` target builds TWRP 3.7 for an Echo Dot (2nd Gen) unlocked with amonet v1.1.0, which runs Fire OS 5.

Upstream's `biscuit` is for amonet v2.0.0, whose bootloader starts a 32-bit kernel; v1.1.0's starts only a 64-bit one. So this fork's `biscuit` has:

- the kernel from [bboe/android_kernel_amazon_biscuit](https://github.com/bboe/android_kernel_amazon_biscuit), in place of upstream's 32-bit one: Amazon's Fire OS 5.5.5.4 kernel, with the SELinux and `mmap_rnd_bits` back-ports Android 9's `init` needs;
- `bootopt=64S3,32N2,64N2` and the load addresses v1.1.0's bootloader expects;
- `TARGET_USES_64_BIT_BINDER`, because the kernel is 64-bit and the recovery's userspace 32-bit;
- no Python, which nothing here uses, and `ro.twrp.source` naming this repository;
- its own build numbers: it reports `3.7.0_9-bboe1`, and each release is tagged and named the same, as `twrp-3.7.0_9-bboe1-biscuit.img`.

It does not boot on a Dot unlocked with amonet v2.0.0.

## Building

`.github/build.sh WORK DEST` syncs TWRP's `twrp-9.0` minimal manifest into WORK, with two projects this tree needs and TeamWin's sources lack, each pinned to a commit:

- `bootable/recovery` from [amazon-oss](https://github.com/amazon-oss/android_bootable_recovery), whose `android-9` branch is TeamWin's with eleven commits for these Echo devices, among them the screenless UI and LED status hook;
- [bengris32's bcbtool](https://github.com/bengris32/bcbtool), which the A/B boot control links.

It adds this tree and the kernel from release `v0.1`, checked against its SHA-256, builds `recovery.img`, and copies it into DEST with `manifest.xml`, the revision of every synced project. It needs Ubuntu 20.04 with the packages `.github/container.sh` installs, or Docker:

```sh
docker run --rm --hostname github -v "$PWD:/tree" -v /mnt/twrp:/work ubuntu:20.04 /tree/.github/container.sh
```

## Verifying a release

```sh
gh attestation verify twrp-3.7.0_9-bboe1-biscuit.img --repo bboe/twrp_device_amazon_echo-mt8163
```
