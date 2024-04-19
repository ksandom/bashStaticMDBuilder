# Filesystem management of input files.

function getDocs
{
    if [ "$1" == '' ]; then
        fileType=""
    else
        fileType=" -type $1"
    fi

    cd src/site
    find . "$fileType" -iname '*.md'
    cd .. # TODO Is this really needed?
}
