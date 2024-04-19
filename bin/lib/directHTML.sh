# Direcctly generate HTML.

function openDiv
{
    local divName="$1"
    local indentation="$2"

    echo -e "\n$indentation<DIV CLASS=\"$divName\">"
}

function closeDiv
{
    local divName="$1"
    local indentation="$2"

    echo -e "\n$indentation</DIV><!-- Close DIV \"$divName\" --> "
}

function heading
{
    local level="$1"
    local value="$2"

    echo "<H$level>$value</H2>"
}

