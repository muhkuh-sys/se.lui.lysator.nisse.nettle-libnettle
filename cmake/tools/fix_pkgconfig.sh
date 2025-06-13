#! /bin/bash
set -e

SEARCHPATH=$1
echo '*** Fix PKGCONFIG files in path ${SEARCHPATH}'
find ${SEARCHPATH} -name "*.pc"
find ${SEARCHPATH} -name "*.pc" -exec sed --expression="s/prefix=[^\n\r]\+/prefix=\$\{pcfiledir\}\/../" --in-place '{}' \;
