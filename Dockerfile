# Synth Host with VNC access to video (but sound goes by wires)

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

from base-ubuntu as vncsvr

run env DEBIAN_FRONTEND=noninteractive apt install -y tigervnc-standalone-server tigervnc-xorg-extension
run apt-fast install -y xterm less
run apt-fast install -y x11-apps
run apt-fast install -y mesa-utils

run env DEBIAN_FRONTEND=noninteractive apt-fast install -y xinit alsa-utils locales libturbojpeg0-dev
run env DEBIAN_FRONTEND=noninteractive apt-fast install -y xfce4 dbus-x11 --no-install-recommends
run env DEBIAN_FRONTEND=noninteractive apt-fast install -y adwaita-icon-theme-full xfce4-terminal wget

run apt-fast install -y libx11-dev libglu1-mesa-dev libxrandr-dev \
    libxinerama-dev libxcursor-dev libxi-dev zlib1g-dev libasound2-dev \
    libgtk2.0-dev libjack-jackd2-dev unzip 


run locale-gen en_US.UTF-8

add xvnc@.service /lib/systemd/system
add xvnc@.socket /lib/systemd/system
add usrbin /usr/bin
run systemctl enable xvnc@0.socket
run systemctl enable xvnc@1.socket
run systemctl disable avahi-daemon.service
run ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
## Finally clean up

run apt-fast clean
run apt-get clean autoclean
run apt-get autoremove -y
run rm -rf /var/lib/apt
run rm -rf /var/lib/dpkg
run rm -rf /var/lib/cache
run rm -rf /var/lib/log
run rm -rf /tmp/*

from scratch
copy --from=vncsvr / / 
copy --from=vcv-docker_vcv /*.zip /


