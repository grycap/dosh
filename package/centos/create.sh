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

tar czf dosh-${VERSION}.tar.gz -C $SRCFOLDER/.. --transform "s/src/dosh-${VERSION}/" src 
cp dosh-${VERSION}.tar.gz ~/rpmbuild/SOURCES/
rpmbuild -ba dosh.spec
cp ~/rpmbuild/RPMS/noarch/dosh-${VERSION}-${REVISION}.noarch.rpm .