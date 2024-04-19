# Inserting videos into documents.

function videos
{
    local IFS="\n"

    while IFS= read -r line; do
        if [ "${line::29}" == "https://www.youtube.com/watch" ] || [ "${line::28}" == "http://www.youtube.com/watch" ] || [ "${line::17}" == "https://youtu.be/" ]; then
            id="$(echo "$line" | sed 's/^.*\(v=\|\.be\/\)//g;s/&.*$//g')"
            echo '<iframe class="video" width="560" height="315" src="https://www.youtube.com/embed/'"$id"'" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'
        elif [ "${line::18}" == 'https://vimeo.com/' ]; then
            id="$(echo "$line" | cut -d/ -f4)"
            echo '<iframe src="https://player.vimeo.com/video/'"$id"'" class="video" width="640" height="360" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>'
        else
            echo "$line"
        fi
    done

    IFS=" "
}
