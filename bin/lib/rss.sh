# Handle RSS feeds.

function buildRSSFeeds
{
    echo "buildRSSFeeds"
    while read -r feed; do
        _buildRSSFeed "$feed" &
    done
    wait
}

function _buildRSSFeed
{
    local feedName="$1"
    local fileName="build/rss/$feedName.rss"

    [ "$doDebug" -gt 0 ] && echo "Build feed $feedName."

    local tag="$feedName"
    cat "src/templates/head.rss" | templatePipe > "$fileName"

    cat "intermediate/feed/$feedName" >> "$fileName"

    cat "src/templates/foot.rss" \
        >> "$fileName"
}
