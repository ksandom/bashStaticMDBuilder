# Filesystem management of output files.

function getOutName
{
    local name="$1"

    if [ "$(basename "$name")" == 'README.md' ]; then
        echo "$(dirname "$name")/index.html"
    else
        echo "$name" | sed 's/md$/html/g'
    fi
}

function assertDir
{
    local name="$(dirname "$1")"

    if [ "$name" != '/' ]; then
        mkdir -p "$name"
    fi
}

function getImageName
{
    local inputName="$1"
    local suffix="$2"

    local extension="$(echo "$inputName" | sed 's/^.*\.//g')"
    local name="$(echo "$inputName" | sed "s/\.$extension$//g")"

    echo "$name$suffix.$extension"
}
