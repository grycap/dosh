#!/bin/bash

SRCFOLDER=$1
if [ "$SRCFOLDER" == "" ]; then
  SRCFOLDER="."
fi

VERSION=$(cat "$SRCFOLDER/version")
if [ $? -ne 0 ]; then
  echo "could not find the version for the package"
  exit 1
fi

FNAME=dosh_${VERSION}
mkdir -p "${FNAME}/bin"
mkdir -p "${FNAME}/DEBIAN"
mkdir -p "${FNAME}/etc/sudoers.d"

cp $SRCFOLDER/dosh $SRCFOLDER/shell2docker "${FNAME}/bin/"
cp $SRCFOLDER/dosh.conf "${FNAME}/etc/"
cp $SRCFOLDER/dosh.sudoers "${FNAME}/etc/sudoers.d/dosh"

cat > "${FNAME}/DEBIAN/control" << EOF
Package: dosh
Version: $VERSION
Section: base
Priority: optional
Architecture: all
Depends: sudo (>=1.8), gettext, bash
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
mkdir -p /etc/dosh/conf.d
chown root:root /etc/sudoers.d/dosh /etc/dosh.conf
chown -R root:root /etc/dosh/conf.d
chmod 400 /etc/sudoers.d/dosh
chmod 600 /etc/dosh.conf
chmod -R 700 /etc/dosh/
chown root:root /bin/dosh /bin/shell2docker
chmod 755 /bin/dosh /bin/shell2docker
if [ -e /etc/shells ]; then
  sed -i /etc/shells '/^\/bin\/dosh$/d'
fi
echo '/bin/dosh' >> /etc/shells
EOF

cat > "${FNAME}/DEBIAN/postrm" <<\EOF
#!/bin/sh
if [ -e /etc/shells ]; then
  sed -i /etc/shells '/^\/bin\/dosh$/d'
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

dpkg-deb --build "${FNAME}"