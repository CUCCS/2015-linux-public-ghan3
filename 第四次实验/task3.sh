#!/bin/bash

function getTopHost {
    topHost=$(awk -F '\t' '{a[$1]++} END {for(i in a) {print a[i],i}}' "$1" | sort -nr -k1 |head -n 100)
    echo "$topHost"
}

function getTopIP {
    topIP=$(awk -F '\t' '{a[$1]++} END {for(i in a) {print a[i],i}}' "$1" | egrep "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}"| sort -nr -k1 |head -n 100)
    echo "$topIP"
}

function getTopUrl {
    topUrl=$(awk -F '\t' '{a[$5]++} END {for(i in a) {print a[i],i}}' "$1" | sort -nr -k1 |head -n 100)
    echo "$topUrl"
}

function StatusCode {
    result=$(sed -e '1d' "$1" | awk -F '\t' '{a[$6]++;b++} END {for(i in a) {print i,a[i],a[i]/b*100 "%"}}' | column -t)
    echo "$result"
}

function 4xxStatusCode {
    code=$(awk -F '\t' '{print $6}' "$1" | egrep "^4[[:digit:]]{2}" | sort -u )
    for i in $code ; do 
        top=$(awk -F '\t' '{ if($6=="'$i'") {count[$5]++}} END { for(c in count) {print count[c],c}}' "$1"|sort -nr -k1 | head -n 10)
        echo "$top" 
    done
}

function urlTop {
    top=$(awk -F '\t' '{if($5=="'$2'") {count[$1]++}} END {for(c in count) {print count[c],c}}' "$1" |sort -nr -k1 |head -n 10)
    echo "$top"
}

function HelpManual {
    echo "Usage: bash "$0" [options]"
    echo "Options: "
    echo "-sh , --sourcehost           Get the TOP 100 source hosts and the corresponding total number of occurrences"
    echo "-si , --sourceip             Get the TOP 100 source IPs and the corresponding total number of occurrences"
    echo "-ut , --urltop               Get the most TOP 100 frequently visited URLs"
    echo "-rc , --responsecode         Get eht number of occurrences and corresponding percentages of different response status codes"
    echo "-4t , --4xxtop               Count the TOP 10 URLs corresponding to different 4xx status codes and the total number of occurrences"
    echo "-su , --specifiedurl <URL>    Get the TOP 100 source hosts for specified URLs"
}

if [ "$#" == 0 ]
then
    HelpManual
fi

while [ "$1" != "" ];do
    case "$1" in
        "-sh" | "--sourcehost" )
            getTopHost "web_log.tsv"
            shift ;;
        "-si" | "--sourceip" )
            getTopIP "web_log.tsv"
            shift ;;
        "-ut" | "--urltop" )
            getTopUrl "web_log.tsv"
            shift ;;
        "-rc" | "--responsecode" )
            StatusCode "web_log.tsv"
            shift ;;
        "-4t" | "--4xxtop" )
            4xxStatusCode "web_log.tsv"
            shift ;;
        "-su" | "--specifiedurl" )          
            urlTop "web_log.tsv" "$2"
            shift 2 ;;
        "-h" | "--help" )
            HelpManual
            exit 0
    esac
done

