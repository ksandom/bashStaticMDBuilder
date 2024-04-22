# Managing lists of documents.

function getLists
{
    local listsLocation="$1"
    cd "$listsLocation"
    ls -1
    cd ~-
}

function buildList
{
    # This is intended to be run from the script root. So no sub directories.
    #rss build/rss 10
    local listOrigin="$1"
    local type="$2"
    local destination="$3"
    local limit="$4"

    echo "buildList $type"
    while read -r feed; do
        _buildList "$feed" &
    done
    wait
}

function _buildList
{
    local feed="$1"

    [ "$doDebug" -gt 0 ] && echo "Build feed contents $feed."

    filePath="$destination/$feed"
    rm -f "$filePath"
    if [ -e "$listOrigin/$feed" ]; then
        while read -r releaseDate item; do
            # TODO Test for item==feed
            if [ -e "intermediate/$type/$item" ]; then
                cat "intermediate/$type/$item" >> "$filePath"
            fi
        done < <(cat "$listOrigin/$feed")
    fi
}

function deriveLatest
{
    head -n "$howManyPostsOnRoot" intermediate/tags/latestContender > intermediate/tags/latest
}
