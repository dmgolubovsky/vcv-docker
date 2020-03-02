# Dockerfile to build a container with VCV-rack

from ubuntu:18.04 as base-ubuntu

run cp /etc/apt/sources.list /etc/apt/sources.list~
run sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
run apt -y update
run apt install -y --no-install-recommends software-properties-common apt-utils
run add-apt-repository -y ppa:apt-fast/stable
run apt -y update
run env DEBIAN_FRONTEND=noninteractive apt-get -y install apt-fast
run echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections
run echo debconf apt-fast/dlflag boolean true | debconf-set-selections
run echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections

run echo "MIRRORS=( 'http://archive.ubuntu.com/ubuntu, http://de.archive.ubuntu.com/ubuntu, http://ftp.halifax.rwth-aachen.de/ubuntu, http://ftp.uni-kl.de/pub/linux/ubuntu, http://mirror.informatik.uni-mannheim.de/pub/linux/distributions/ubuntu/' )" >> /etc/apt-fast.conf

run apt-fast -y update && apt-fast -y upgrade

from base-ubuntu as vcv-rack

run apt-fast install -y wget unzip git gdb curl cmake libx11-dev libglu1-mesa-dev libxrandr-dev \
    libxinerama-dev libxcursor-dev libxi-dev zlib1g-dev libasound2-dev \
    libgtk2.0-dev libjack-jackd2-dev jq

workdir /build-rack
run git clone https://github.com/VCVRack/Rack.git
workdir Rack

run git checkout v1.1.6
run git submodule update --init --recursive

run make -j4 dep

run make -j4

workdir plugins

run git clone https://github.com/VCVRack/Fundamental.git
workdir Fundamental
run git submodule update --init --recursive
run make dep
run make
run apt install -y zip
run make dist

run ls -l dist

workdir /build-rack/Rack
run cp plugins/Fundamental/dist/Fundamental-1.4.0-lin.zip Fundamental.zip
run make dist

from scratch as install-rack

copy --from=vcv-rack /build-rack/Rack/dist/*.zip /
copy --from=vcv-rack /build-rack/Rack/plugins/Fundamental/dist/*.zip /






