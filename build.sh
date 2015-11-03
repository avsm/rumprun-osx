#!/usr/bin/env bash

set -ex

DESTDIR=${DESTDIR:-`pwd`}
CROSSENV="${DESTDIR}/cross-env.sh"
RRENV="${DESTDIR}/rr-env.sh"
cd ${DESTDIR}

if [ ! -d netbsd ]; then
  git clone -b netbsd-7 https://github.com/IIJ-NetBSD/netbsd-src.git netbsd
elif [ -d netbsd/.git ]; then
  git -C netbsd pull -u
fi

cd netbsd
./build.sh -U -T elftools.x86_64 -m amd64 tools

echo export PATH=\"$DESTDIR/netbsd/elftools.x86_64/bin:\$PATH\" > ${CROSSENV}
echo export READELF=\"$DESTDIR/netbsd/elftools.x86_64/bin/x86_64--netbsd-readelf\" >> ${CROSSENV}
echo export CC=\"x86_64--netbsd-gcc\" >> ${CROSSENV}
chmod a+x ${CROSSENV}

cd ${DESTDIR}
eval `cat ${CROSSENV}`

bash

if [ ! -d rumprun ]; then
  git clone http://repo.rumpkernel.org/rumprun
  git -C rumprun submodule update --init
elif [ -d rumprun/.git ]; then
  git -C rumprun pull -u
  # TODO something with submodules here?
fi

cd rumprun
./build-rr.sh hw

echo export PATH=\"$DESTDIR/rumprun/rumprun/bin:\$PATH\" > ${RRENV}
chmod a+x ${RRENV}
