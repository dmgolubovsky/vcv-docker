# Build a standalone rack with plugins to use with host X server
# rather than VNC

from ubuntu:18.04 as rackinit

copy --from=vcv-docker_vcv /*.zip /

run apt -y update

run apt install -y unzip libgl1

workdir /

workdir /root

run mv /Rack-1.1.6-lin.zip /root

run unzip Rack-1.1.6-lin.zip

workdir /root/.Rack/plugins-v1

run mv /*.zip .

from ubuntu:18.04 as xrack

copy --from=rackinit /root /root

run apt -y update

run apt install -y --no-install-recommends libgl1 libasound2 libjack-jackd2-0 libgtk2.0-0 wget sox

workdir /tmp

run wget --no-check-certificate https://musical-artifacts.com/artifacts/133/drumkits.tar.bz2

run tar xjvf drumkits.tar.bz2

run mkdir -p /usr/share/hydrogen/data

run mv drumkits /usr/share/hydrogen/data

run rm  /tmp/drumkits.tar.bz2

workdir /usr/share/hydrogen/data

run for f in $(find . -name '*.flac' -o -name '*.aiff') ; do (sox "$f" "$f.wav" || true) ; done

from scratch

copy --from=xrack / /

workdir /root/Rack

cmd "./Rack"



