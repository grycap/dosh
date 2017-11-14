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
REVISION=${VERSION##*-}
VERSION=${VERSION%%-*}

tar czf dosh-${VERSION}.tar.gz -C $SRCFOLDER/.. --transform "s/src/dosh-${VERSION}/" src 
cp dosh-${VERSION}.tar.gz ~/rpmbuild/SOURCES/
rpmbuild -ba dosh.spec
cp ~/rpmbuild/RPMS/noarch/dosh-${VERSION}-${REVISION}.noarch.rpm .