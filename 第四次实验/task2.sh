#!/bin/bash


# get the line number for Age/Name/Position
function getColNum {
    firstRow=($(awk 'NR==1{print}' "$1"))
    ColNum=1
    for item in "${firstRow[@]}";do
        if [[ "$item" != "$2" ]]
        then
            ColNum=$(($ColNum+1))
        else break
        fi
    done
    echo "$ColNum"
}

# get the number and percentage of players in different age ranges
# get the youngest and the oldest players' name
function AgeProcess {
    AgeColNum=$(getColNum "$1" "Age")
    NameColNum=$(getColNum "$1" "Player")
    # get the age colunm
    tmp="\$"${AgeColNum}
    ageColumn=($(awk -F '\t' "{print $tmp}" "$1" ))&& unset ageColumn[0]
    
    count=1
    below20=0
    above30=0
    between2030=0
    youngest=20
    oldest=30
    for age in "${ageColumn[@]}"; do
        tmp="\$"${NameColNum}
        if [[ "$age" -lt "20" ]]; then
            below20=$(($below20+1))
            if [[ "$age" -lt "$youngest" ]]; then
                youngest="$age"
                youngestp=$(awk -F '\t' "NR==(($count+1)){print $tmp}" "$1")
            fi
        elif [[ "$age" -gt "30" ]]; then
            above30=$(($above30+1))
            if [[ "$age" -gt "$oldest" ]]; then
                oldest="$age"
                oldestp=$(awk -F '\t' "NR==(($count+1)){print $tmp}" "$1")
            fi
        else
            between2030=$(($between2030+1))
        fi
        count=$(($count+1))
    done
    
    count=$(($count-1))
    echo "The number of people under 20 is : $below20 , and the percentage is $(echo $below20 $count |awk '{printf "%0.2f\n" ,$1/$2*100}')%"
    echo "The number of people between 20 and 30 is : $between2030 , and the percentage is $(echo $between2030 $count |awk '{printf "%0.2f\n" ,$1/$2*100}')%"
    echo "The number of people above 30 is : $above30 , and the percentage is $(echo $above30 $count |awk '{printf "%0.2f\n" ,$1/$2*100}') %"
    echo ""
    echo "The yougest player is : $youngestp , age is $youngest "
    echo "The oldest player is : $oldestp , age is $oldest "
    echo ""
}


function position {
    PosColNum=$(getColNum "$1" "Position")
    tmp="\$"${PosColNum}
    posColumn=($(awk -F '\t' "{print $tmp}" "$1" ))&& unset posColumn[0]
   
    count=0
    declare -A dic
    for pos in "${posColumn[@]}"; do
        if [[ ${dic[$pos]} ]]; then
            dic[$pos]=$((${dic[$pos]}+1))
        else dic[$pos]=1
        fi
        count=$(($count+1))
    done
    
    for key in ${!dic[@]}; do 
        echo "$key : ${dic[$key]} , the percentage is $(echo ${dic[$key]} $count |awk '{printf "%0.2f\n" ,$1/$2*100}')%"
    done     
    
}

function namelength {
    nameColNum=$(getColNum "$1" "Player")
    tmp="\$"${nameColNum}
    nameLength=$( awk -F '\t' "{print length($tmp)}" $1)
 
    count=0
    longest=0
    shortest=30
    for length in $nameLength; do 
        if [[ $length -gt $longest ]]; then
            longest="$length"
            longestp=$(awk -F '\t' "NR==(($count+1)){print $tmp}" "$1")
        fi
        if [[ $length -lt $shortest ]]; then
            shortest="$length"
            shortestp=$(awk -F '\t' "NR==(($count+1)){print $tmp}" "$1")
        fi
        count=$(($count+1))
    done

    echo "The longest name player is : $longestp"
    echo "The shortest name player is : $shortestp"
}


function HelpManual {
    echo "Usage: bash "$0" [options]"
    echo "Options: "
    echo "-n , --name           Get the number and percentage of players in different age ranges and get the youngest and the oldest players' name"
    echo "-p , --position       Get the number and the percentage of players in different positions on the field"
    echo "-l , --length         Get the longest and shortest name of players"
}


if [ "$#" == 0 ]
then
    HelpManual
fi

while [ "$1" != "" ];do
    case "$1" in
        "-n" | "--name" )
            AgeProcess "worldcupplayerinfo.tsv"
            shift ;;
        "-p" | "--position" )
            position "worldcupplayerinfo.tsv"
            shift ;;
        "-l" | "--length" )
            namelength "worldcupplayerinfo.tsv"
            shift ;;
        "-h" | "--help" )
            HelpManual
            exit 0
    esac
done

