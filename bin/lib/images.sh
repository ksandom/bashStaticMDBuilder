# Image processing.

function images
{
    local myTag="$1"
    local IFS="\n"

    while IFS= read -r line;do
        if [ "${line::2}" == '![' ]; then
            description="$(echo "$line" | sed 's/^..//g; s/\].*$//g')"
            file="$(echo "$line" | sed 's/^.*(//g; s/).*$//g')"

            if [ "${file: -4}" == '.svg' ] || [ "${file: -4}" == '.SVG' ]; then
                previewFile="$file"
                imageFile="$file"
            else
                previewFile="$(getImageName "$file" "_preview")"
                imageFile="$(getImageName "$file" "_viewable")"

                if [ -f "$myTag/$file" ]; then
                    imageMaxSize "$myTag/$file" "$myTag/$previewFile" "$previewMaxSize"
                    imageMaxSize "$myTag/$file" "$myTag/$imageFile" "$useableMaxSize"

                    rm "$myTag/$file"
                fi
            fi

            prefix=''
            if [ "$myTag" == 'welcome' ]; then
                prefix='/welcome/'
            fi

            if [ -f "$myTag/$previewFile" ] && [ -f "$myTag/$imageFile" ] ; then
                echo "<p class=\"insertedImageWrapper\"><a href=\"$prefix$imageFile\" target=\"_blank\"><img alt=\"$description\" class=\"insertedImage\" src=\"$prefix$previewFile\" /></a><br>Above: $description</p>"
            else
                echo "Could not find \"$myTag/$previewFile\" & \"$myTag/$imageFile\" in \"$(pwd)\". So this has been skipped in the final output." >&2
            fi
        else
            echo "$line"
        fi
    done

    IFS=" "
}

function makeThumbnail
{
    local inFile="$1"
    local outFile="$2"

    if [ ! -f "$outFile" ]; then
        mkdir -p "$(dirname "$outFile")"
        convert -resize "$thumbnailSize" "$inFile" "$outFile"
    fi
}

function getDimensions
{
    local dimCache="../intermediate/dimCache"
    mkdir -p "$dimCache"
    local key="$(echo "$(pwd)/$1" | md5sum | cut -d\  -f1)"
    local dimCacheFile="$dimCache/$key"

    if [ ! -e "$dimCacheFile" ]; then
        identify -format "%w %h" "$1" | sed 's/ .* / /g' > "$dimCacheFile"
    fi

    cat "$dimCacheFile"
}

function imageMaxSize
{
    local imageInFile="$1"
    local imageOutFile="$2"
    local imageMaxSize="$3"
    local IFS=" "

    if [ -e "$imageOutFile" ]; then
        true # Don't do anything if we already have it. This can be re-done by doing a ./bin/freshBuild
    elif [ -e "$imageInFile" ]; then
        read x y < <(getDimensions "$imageInFile")

        echo "imageMaxSize: Comparing $x to $y. imageMaxSize=$imageMaxSize. file=$imageInFile" >&2
        if [ "$x" -gt "$y" ]; then
            if [ "$x" -gt "$imageMaxSize" ]; then
                let newY=$y*$imageMaxSize/$x
                convert -resize "${imageMaxSize}x${newY}" "$imageInFile" "$imageOutFile"
            else
                cp "$imageInFile" "$imageOutFile"
            fi
        else
            if [ "$y" -gt "$imageMaxSize" ]; then
                let newX=$x*$imageMaxSize/$y
                convert -resize "${newY}x${imageMaxSize}" "$imageInFile" "$imageOutFile"
            else
                cp "$imageInFile" "$imageOutFile"
            fi
        fi
    else
        echo "imageMaxSize: Could not find \"$imageInFile\"." >&2
    fi
}
