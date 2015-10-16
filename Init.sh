#!/bin/sh

prjdir="$1"
# * Argument check
if [[ -z "$prjdir" ]];then
    echo -n 'Your project name (directory name): '
    read prjdir
fi

if [[ -d "$prjdir" ]]; then
    echo "Error: ${prjdir} already exists."
    exit 1;
fi

# * Download
TMPDIR=`mktemp --tmpdir=/tmp -d webdev-prototype-XXX` # force /tmp
cd ${TMPDIR}
wget -nv https://github.com/carltonf/webdev-prototype/archive/master.zip
unzip master.zip 

cd -
mv ${TMPDIR}/webdev-prototype-master ${prjdir}

# * Clean up
rm -rf ${TMPDIR}

# * Post init
cd ${prjdir}
# ** Git
git init
git add .
git commit -am 'init from proto'
# remove this init script itself.
rm -f Init.sh

npm install
