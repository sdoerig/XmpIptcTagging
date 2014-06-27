#!/bin/bash
# ------------------------------------------------------------------
# tagPictures
# Description:
#     Tags a bunch of pictures according to a CSV file
#     provided by geo-fotos.ch 
#          
# Dependency:
#     http://www.sno.phy.queensu.ca/~phil/exiftool/
#
# Exit codes:
#     0
#       Everything went well
#     1
#       Path to file given with option -t does not point
#       to a regular file
#     2 Path to picture directory given with option -d does
#       not point to a regular directory 
# Author:
#     sdoerig@bluewin.ch
# ------------------------------------------------------------------



declare CSV=''
declare DIR='.'
declare VERBOSE=0
declare LOGFILE=""


# Getting the options where as
# -t: tagfile
# -d: directory - where to find the pictures to be 
#     tagged
# -l: logfile
# -v: verbose prints the tags to STDOUT
#      
while getopts ":t:d:l:v" opt; do
    case $opt in
	t)
	    CSV=$OPTARG
	;;
	d)
	    DIR=$OPTARG
	;;
	l)
	    LOGFILE=$OPTARG
	;;
	v)
	    VERBOSE=1
	;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    echo "Usage:"
	    echo $0" -t <tagFile> -d <pictureDirectory> -l <logfile|tagPictures.log>"
	;;
    esac
done


function logError {
    local msg="$@"
    log "ERROR - " $msg
}

function logInfo {
    local msg="$@"
    log "INFO - " $msg
}

function log {
    local msg="$@"
    echo $(date +%Y-%m-%d_%H:%M:%S)" "$msg >> ${LOGFILE:-"tagPictures.log"}
}

function tagFile {
    local diaNo=$1
    local place=$2
    local canton=$3
    local motiv=$4
    local region=$5
    local season=$6
    local placeOfTaking=$7
    local format=$8
    local storage=$9
    local res=${10}
    # Do not allow substring matches. Example:
    # diaNo is 23 and in the directory
    # the files 
    # - 23.tif
    # - 233.tif
    # are available. So it would be completly wrong
    # to match 233 also. This is prevented by
    # [^0-9].
    for f in $DIR/$diaNo[^0-9]* 
    do 
	if [ $f != "$DIR/$diaNo[^0-9]*" ]
	then
	  
	    logInfo "Reserve ->"$res"---"
	    echo "Tagging file "$f
	    echo "Reserve ->"$res"---"
	    resTags=""
	    if [ $res ]
	    then 
		resTags="-XMP:Subject="$res" -iptc:keywords="$res
	    fi
	    exiftool -E \
		-XMP:Subject=$diaNo -iptc:keywords=$diaNo \
		-XMP:Subject=$place -iptc:keywords=$place \
    		-XMP:Subject=$canton -iptc:keywords=$canton \
		-XMP:Subject=$motiv -iptc:keywords=$motiv \
		-XMP:Subject=$region -iptc:keywords=$region \
		-XMP:Subject=$season -iptc:keywords=$season \
		-XMP:Subject=$placeOfTaking -iptc:keywords=$placeOfTaking \
		-XMP:Subject=$format -iptc:keywords=$format \
		-XMP:Subject=$storage -iptc:keywords=$storage \
		$resTags $f
	    logInfo "exiftool exit code: "$?" - "$f
	fi
    done
    
}

function readCSV {
    logInfo $0" START"
    if [ ! -f $CSV ]
    then
	echo "FATAL: "$CSV" is not a regular file"
	logError $CSV" is not a regular file"
	exit 1
    elif [ ! -d $DIR ]
    then
	echo "FATAL: "$DIR" is not a directory"
	logError $DIR" is not a directory"
	exit 2
    fi
    echo $CSV"-->"$DIR
    #Dia-Nr;Ortschaft;Kant.;Motiv;Region;Jahreszeit;Aufnahmeort;Format;Scaner;Find;Abl.;Reserve;;;;
    export IFS=\; 
    while read -r diaNo place canton motiv region \
	season placeOfTaking format scanner find storage res 
    do
	if [ $VERBOSE = 1 ] 
	then
	    
	    echo "Dia-Nr -> "$diaNo
	    echo "Ortschaft ->"$place
	    echo "Kant. ->"$canton
	    echo "Motiv ->"$motiv
	    echo "Region ->"$region
	    echo "Jahreszeit ->"$season
	    echo "Aufnahmeort ->"$placeOfTaking
	    echo "Format ->"$format
	    echo "Abl. ->"$storage
	    echo "Reserve ->"$res"-"
	    echo "================================="

	fi
	
	tagFile $diaNo $place $canton $motiv $region \
	    $season $placeOfTaking $format $storage $res
    done < $CSV
    logInfo $0" END"
    exit 0
}

readCSV