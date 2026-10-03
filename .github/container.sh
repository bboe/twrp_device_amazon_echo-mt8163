#!/bin/bash
# Usage: docker run -v TREE:/tree -v WORK:/work ubuntu:20.04 /tree/.github/container.sh
#
# Installs what an Android 9 build needs, then runs build.sh with WORK as
# its work directory and TREE/dist as its destination.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive LC_ALL=C USER=bboe
apt-get update -qq
apt-get install -y -qq --no-install-recommends \
  bc bison build-essential ca-certificates cpio curl flex g++-multilib \
  gcc-multilib git gperf lib32ncurses5-dev lib32z1-dev libc6-dev-i386 \
  libncurses5 libncurses5-dev libssl-dev libxml2-utils lzop m4 openjdk-8-jdk \
  python python3 rsync schedtool unzip xsltproc zip zlib1g-dev > /dev/null
git config --global --add safe.directory '*'
git config --global user.name build
git config --global user.email build@localhost
git config --global color.ui false
/tree/.github/build.sh /work /tree/dist
