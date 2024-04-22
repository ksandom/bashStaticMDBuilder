# Process templates.

function generateTemplateConfig
{
    echo "s#~!title!~#$title#g; s#~!titleImage!~#$titleImageAbsolutePath#g; s#~!tags!~#$tags#g; s#~!releaseDate!~#$releaseDate#g; s#~!description!~#$description#g; s#~!siteTitle!~#$siteTitle#g; s#~!siteDescription!~#$siteDescription#g; s#~!siteURL!~#$siteURL#g; s#~!title!~#$title#g; s#~!content!~#$content#g; s#~!releaseDate!~#$releaseDate#g; s#~!siteURL!~#$siteURL#g; s#~!myTag!~#$tag#g; s#~!thumbnail!~#$thumbnail#g"
}

function templatePipe
{
    sed "$(generateTemplateConfig)"
}

function templateFile
{
    local fileName="$1"

    sed "$(generateTemplateConfig)" -i "$fileName"
}
