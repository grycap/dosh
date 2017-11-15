#!/bin/bash
#
# DoSH - Docker SHell
# https://github.com/grycap/dosh
#
# Copyright (C) GRyCAP - I3M - UPV 
# Developed by Carlos A. caralla@upv.es
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

SRCFOLDER=$1
if [ "$SRCFOLDER" == "" ]; then
  SRCFOLDER="."
fi
VERSION=$(cat "$SRCFOLDER/version")
if [ $? -ne 0 ]; then
  echo "could not find the version for the package"
  exit 1
fi
REVISION=${VERSION##*-}
VERSION=${VERSION%%-*}

FNAME=build/dosh_${VERSION}-${REVISION}
mkdir -p "${FNAME}/bin"
mkdir -p "${FNAME}/DEBIAN"
mkdir -p "${FNAME}/etc/sudoers.d"
mkdir -p "${FNAME}/etc/dosh/scripts"

cp $SRCFOLDER/bin/dosh $SRCFOLDER/bin/shell2docker "${FNAME}/bin/"
chmod 755 ${FNAME}/bin/*
cp $SRCFOLDER/etc/dosh.conf "${FNAME}/etc/"
cp $SRCFOLDER/etc/scripts/* "${FNAME}/etc/dosh/scripts/"
chmod -x "${FNAME}/etc/dosh/scripts/"
mkdir -p "${FNAME}/etc/dosh/conf.d/"
cp $SRCFOLDER/etc/dosh.sudoers "${FNAME}/etc/sudoers.d/dosh"
chmod 400 "${FNAME}/etc/sudoers.d/dosh"
chmod 700 "${FNAME}/etc/dosh" "${FNAME}/etc/dosh/scripts" "${FNAME}/etc/dosh/conf.d"
chmod 600 "${FNAME}/etc/dosh.conf"

cat > "${FNAME}/DEBIAN/control" << EOF
Package: dosh
Version: ${VERSION}-${REVISION}
Section: base
Priority: optional
Architecture: all
Depends: sudo (>=1.8), gettext, bash, libc-bin, coreutils, docker-engine | docker.io
Maintainer: Carlos A. <caralla@upv.es>
Description: DoSH - Docker SHell
 use Docker containers to run the shell of the users in your Linux system.
 DoSH provides a configurable and secure mechanism to make that when a user 
 logs-in a Linux system, a customized (or standard) container will be created
 for him. This will enable to limit the resources that the user is able to 
 use, the applications, etc. but also provide custom linux flavour for each 
 user or group of users.
EOF

cat > "${FNAME}/DEBIAN/postinst" <<\EOF
#!/bin/sh
if [ ! -f /var/log/dosh.log ]; then
  touch /var/log/dosh.log
  chown root:root /var/log/dosh.log
  chmod 600 /var/log/dosh.log
fi
if [ -e /etc/shells ]; then
  sed -i '/^\/bin\/dosh$/d' /etc/shells
fi
echo '/bin/dosh' >> /etc/shells
EOF

cat > "${FNAME}/DEBIAN/postrm" <<\EOF
#!/bin/sh
if [ -e /etc/shells ]; then
  sed -i '/^\/bin\/dosh$/d' /etc/shells
fi
EOF

chmod +x "${FNAME}/DEBIAN/postinst"
chmod +x "${FNAME}/DEBIAN/postrm"

cat > "${FNAME}/DEBIAN/conffiles" <<\EOF
/etc/sudoers.d/dosh
/etc/dosh.conf
EOF

cd "${FNAME}"
find . -type f ! -regex '.*.hg.*' ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -printf "%P " | xargs md5sum > "DEBIAN/md5sums"
cd -

fakeroot dpkg-deb --build "${FNAME}"