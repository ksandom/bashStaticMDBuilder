# Masks for title image and thumbnail transparency.

function generateMasks
{
    generateMasksForResolution "$titleSize"
    generateMasksForResolution "$thumbnailSize"
}

function generateMasksForResolution
{
    resolution="$1"
    inFilesDir="assets/masks"
    inFiles="$(cd "$inFilesDir"; ls -1 | grep -v '\(extractMasks\|\.xcf\)')"
    outFilesDir="intermediate/masks/$resolution"

    mkdir -p "$outFilesDir"

    echo "generateMasksForResolution $resolution"
    for file in $inFiles; do
        {
        inFile="$inFilesDir/$file"
        outFile="$outFilesDir/$file"

        if [ ! -e "$outFile" ]; then
            convert -resize "$resolution" "$inFile" "$outFile"
            echo "  $file:    Done."
        else
            echo "  $file:    Skipped (Already done)."
        fi
        } &
    done
    wait
}

function maskImage
{
    local fileIn="$1"
    local maskFile="$2"
    local fileOut="$3"
    local resolution="$4"
    local prefix="maskImage $fileIn => $resolution:    "

    local maskCache="intermediate/maskCache"
    mkdir -p "$maskCache"
    local cacheFile="$maskCache/$(echo "$fileIn $maskFile $resolution" | md5sum | cut -d\  -f1)"

    if [ -e "$fileOut" ]; then
        # We've already done this.
        echo "${prefix}Skipping (Already done)."
        return 0
    fi

    if [ -e "$cacheFile" ]; then
        echo "${prefix}Skipping (Using cached file)."
        cp "$cacheFile" "$fileOut"
        return 0
    fi

    if [ ! -e "$fileIn" ]; then
        echo "${prefix}$fileIn (fileIn) does not exist in $(pwd)." >&2
        return 1
    fi

    if [ ! -e "$maskFile" ]; then
        echo "${prefix}$maskFile (maskFile) does not exist in $(pwd)." >&2
        return 1
    fi

    echo "${prefix}Begin. $fileIn + $maskFile -> $fileOut @ $resolution"

    convert -resize "$resolution" "$fileIn" "$fileIn.scaled"
    if [ -e "$fileIn.scaled" ]; then
        maskIn="$fileIn.scaled"
        echo "${prefix}Resized."
    else
        maskIn="$fileIn"
        echo "${prefix}Not resized; Using the original."
    fi

    if [ ! -e "$maskIn" ]; then
        echo "${prefix}$maskIn (maskIn) does not exist in $(pwd)." >&2
        return 1
    fi

    magick "$maskIn" \( +clone -alpha extract "$maskFile" -composite \) -compose CopyOpacity -composite "$fileOut"


    if [ ! -e "$fileOut" ]; then
        echo "${prefix}$fileOut (fileOut) does not exist in $(pwd)." >&2
        return 1
    fi

    cp "$fileOut" "$cacheFile"
    echo "${prefix}Masked."

    rm -f "$fileIn.scaled"
    echo "${prefix}Cleaned."
}
