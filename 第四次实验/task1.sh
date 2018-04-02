#!bin/bash

dir="$1"

# help manual
function HelpManual {
    echo "Usage: bash "$0" [options]"
    echo "Options: "
    echo "-d  , --directory               Specify the path"
    echo "-cq , --compressq <percent>     Image quality compress for jpeg format pictures with compression percentage, percent must with %"
    echo "-cr , --compressr <percent>     Compress image resolution and maintainaspect ratio, percent must with %"
    echo "-wm , --watermark <text>        Add watermark to the images"
    echo "-ap , --addprefix <text>        Add prefix for images"
    echo "-as , --addsufix <text>         Add suffix for images"
    echo "-cf , --convertformat           Convert png/svg images to jpg format"
    exit 0
}

# image quality compression for jpeg format pictures
function compressq {
    # $1:path $2:percentage
    imgs=($(find "$1" ! -path ""$1"output/*" -name "*.jpeg"))
    for img in "${imgs[@]}"; do
        $(convert "$img" -quality "$2" ""$1"output/compressq_${img:${#1}}")
    done 
}

# Compress image resolution
function compressr {
    imgs=($(find "$1" ! -path ""$1"output/*" -name "*.jpeg" -o -name "*.png" -o -name "*.svg"))
    for img in "${imgs[@]}"; do
        $(convert "$img" -resize "$2" ""$1"output/compressr_${img:${#1}}")
    done
}

# Add watermark
function addwatermark {
    imgs=($(find "$1" ! -path ""$1"output/*" -name "*.png"))
    for img in "${imgs[@]}"; do
        width=$(identify -format %w "$img")
        $(convert -background '#0008' -fill white -gravity center -size ${width}x30 caption:"$2" "$img" +swap -gravity south -composite ""$1"output/addwm_${img:${#1}}")
    done
}

# add prefix
function addPrefix {
    imgs=($(find "$1" -regex "\.\/image\/[0-9]\.[a-z]+"))
    for img in "${imgs[@]}"; do
        realname=${img:${#1}}
        newname=${1}"output/"${2}${realname}
        $(cp "$img" "$newname")
    done
}

# add suffix
function addSufix {
    imgs=($(find "$1" -regex "\.\/image\/[0-9]\.[a-z]+"))
    for img in "${imgs[@]}"; do
        fullname=$(basename $img)
        filename=$(echo $fullname | cut -d . -f1)
        extension=$(echo $fullname | cut -d . -f2)
        newname=${1}"output/"${filename}${2}"."${extension}
        $(cp "$img" "$newname")
    done
}

function convertFormat {
    imgs=($(find "$1" ! -path ""$1"output/*" -name "*.png" -o -name "*.svg"))
    for img in "${imgs[@]}"; do
        fullname=$(basename $img)
        filename=$(echo $fullname | cut -d . -f1)
        extension=$(echo $fullname | cut -d . -f2)
        newname=${1}"output/"${filename}".svg"
        $(convert "$img" "$newname")
    done
}

if [ "$#" == 0 ]
then
    HelpManual
fi

while [ "$1" != ""  ];do
    case "$1" in
        "-d" | "--directory" )
            dir="$2"
            shift 2;;
        "-cq" | "--compressq" )
            if [[ "$2" != "" ]]
            then
                compressq "$dir" "$2"
            else echo "you must input the percent for -cq";exit 1
            fi
            shift 2;;
        "-cr" | "--compressr" )
            if [[ "$2" != "" ]]
            then
                compressr "$dir" "$2"
            else echo "you must input the percent for -cr";exit 1
            fi
            shift 2;;
        "-wm" | "--watermark" )
            if [[ "$2" != "" ]]
            then
                addwatermark "$dir" "$2"
            else echo "you must input the watermark";exit 1
            fi
            shift 2;;
        "-ap" | "--addprefix" )
            if [[ "$2" != "" ]]
            then
                addPrefix "$dir" "$2"
            else echo "you must input the prefix";exit 1
            fi
            shift 2;;
         "-as" | "--addsufix" )
            if [[ "$2" != "" ]]
            then
                addSufix "$dir" "$2"
            else echo "you must input the sufix";exit 1
            fi
            shift 2;;
         "-cf" | "--convertformat" )
            convertFormat "$dir" 
            shift ;;
         "-h" | "--help" )
            HelpManual
            exit 0 
    esac
done
