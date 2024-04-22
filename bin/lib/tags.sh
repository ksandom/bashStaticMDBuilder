# Document tags.

function getTagBar
{
    local tags="$1"
    local type="$2"
    local tagBarFile="../intermediate/tagBar/bars/$tags.$type"

    buildTagBar "$tags" "$type"
    cat "$tagBarFile"
}

function buildTagBar
{
    local tags="$1"
    local type="$2"
    local tagBarFile="../intermediate/tagBar/bars/$tags.$type"

    if [ ! -f "$tagBarFile" ]; then
        tagsContents="$(_buildTags "$tags" "$type" | _buildTagsGetContents)"

        cat "../src/templates/tagBar.$type" | \
            sed "s#~!tags!~#$tagsContents#g" \
            > "$tagBarFile"
    fi
}

function _buildTagsGetContents
{
    while read -r fileIn; do
        cat "$fileIn"
    done | tr '\n' ',' | sed 's/,//g' # TODO This is a terrible hack to get rid of \n.
}

function _buildTags
{
    local tags="$1"
    local type="$2"

    # TODO Do this better. Eg it won't handle tags with spaces (which shouldn't happen anyway...). Check if IFS will work here.
    for tag in $(echo $tags | sed 's/,/ /g'); do
        tagFileName="../intermediate/tagBar/tags/$tag.$type"
        buildTag "$tag" "$type" "$tagFileName"
        echo "$tagFileName"
    done
}

function buildTag
{
    local tag="$1"
    local type="$2"
    local tagFileName="$3"

    cat "../src/templates/tag.$type" | \
        sed "s#~!tag!~#$tag#g" \
        > "$tagFileName"

}

function addDocToTags
{
    local doc="$1"
    local date="$2"
    local tags="$3"

    IFS=","

    for tag in $tags; do
        addDocToTag "$doc" "$date" $tag
    done

    IFS=" "
}

function addDocToTag
{
    # This is assumed to be  run from inside addDocToTags, inside buildDocs. Therefore the it will be executed inside the ./build directory, so all paths are relative to that.
    local tagPath="../intermediate/tags"

    local doc="$1"
    local date="$2"
    local tag="$3"

    if [ "$doc" == '' ] || [ "$date" == '' ] || [ "$tag" == '' ] ; then
        echo "Could not add doc '$doc' to tag '$tag' on date '$date'." >&2
        return 1
    else
        echo "$date $doc" >> "$tagPath/$tag.raw"
    fi
}

function sortTags
{
    cd  intermediate/tags

    echo -n "Sorting tags..."
    for tag in *.raw;do
        sort -ur "$tag" > "$tag.sorted"
        shortTag="$(echo "$tag" | sed 's/\.raw$//g')"
        mv "$tag.sorted" "$shortTag"
        rm "$tag"

        generateRelated "$shortTag"
    done
    wait
    echo "Done."

    cd ../.. # TODO Is this really needed?
}

function getUniqueTags
{
    local tags="$1"
    echo "$tags" | sed 's/,/\n/g' | sort -u | grep -v '^$' | tr '\n' ',' | sed 's/,$//g'
}

function saveTagCombo
{
    # Assumed to be called within the prep. So inside the ./build directory.
    local tagCombo="$1"
    touch "../intermediate/tagCombos/$tagCombo"
}

function fillTagCombos
{
    # Assumed to be called from the script root. So not inside any sub-directory.
    cd intermediate/tagCombos

    echo "fillTagCombos."
    for tagCombo in *; do
        [ "$doDebug" -gt 0 ] && echo "  Fill tagCombo $tagCombo."
        for tag in $(echo $tagCombo | sed 's/,/\n/g'); do
            [ "$doDebug" -gt 1 ] && echo "    $tag" >&2
            cat "../tags/$tag"
        done | sort -ru | grep -v ' welcome' > "$tagCombo"
    done

    cd ~-
}

