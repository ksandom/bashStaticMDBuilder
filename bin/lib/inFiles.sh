# Filesystem management of input files.

function getDocs
{
    type="$1"
    regexFilter="$2"

    if [ "$type" == '' ]; then
        fileType=""
    else
        fileType=" -type $type"
    fi

    if [ "$regexFilter" == '' ]; then
        regexFilter='.*'
    fi

    cd src/site
    find . $fileType -iname '*.md' | grep "$regexFilter"
    cd .. # TODO Is this really needed?
}
