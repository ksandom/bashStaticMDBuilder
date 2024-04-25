# Stuff to make caching easier.

function getCacheDir
{
    local cacheName="$1"
    local cacheDir="../intermediate/cache/$cacheName"

    mkdir -p "$cacheDir"

    echo "$cacheDir"
}

function getCacheName
{
    local IDData="$1"

    echo "$IDData" | md5sum | cut -d\  -f1
}

function getCacheEntry
{
    local cacheName="$1"
    local IDData="$2"

    echo "$(getCacheDir "$cacheName")/$(getCacheName "$IDData")"
}
