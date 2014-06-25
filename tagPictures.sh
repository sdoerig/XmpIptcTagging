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
# Author:
#     sdoerig@bluewin.ch
# ------------------------------------------------------------------



declare CSV=''
declare DIR='.'
declare VERBOSE=0



# Getting the options where as
# -t: tagfile
# -d: directory - where to find the pictures to be 
#     tagged
# -v: verbose prints the tags to STDOUT
#      
while getopts ":t:d:v" opt; do
    case $opt in
	t)
	    CSV=$OPTARG
	;;
	d)
	    DIR=$OPTARG
	;;
	v)
	    VERBOSE=1
	;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    echo "Usage:"
	    echo $0" -t <tagFile> -d <pictureDirectory>"
	;;
    esac
done


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
    # Do not allow substring matches. Examle:
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
 
	    echo "Tagging file"$f
	    exiftool -E -XMP:Subject=$place -iptc:keywords=$place \
    		-XMP:Subject=$canton -iptc:keywords=$canton \
		-XMP:Subject=$motiv -iptc:keywords=$motiv \
		-XMP:Subject=$region -iptc:keywords=$region \
		-XMP:Subject=$season -iptc:keywords=$season \
		-XMP:Subject=$placeOfTaking -iptc:keywords=$placeOfTaking \
		-XMP:Subject=$format -iptc:keywords=$format \
		-XMP:Subject=$storage -iptc:keywords=$storage $f
	fi
    done
    
}

function readCSV {
    echo $CSV"-->"$DIR
    #Dia-Nr;Ortschaft;Kant.;Motiv;Region;Jahreszeit;Aufnahmeort;Format;Scaner;Find;Abl.;Reserve;;;;
    export IFS=\; 
    while read -r diaNo place canton motiv region season placeOfTaking format scanner find storage 
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
	    echo "================================="

	fi
	tagFile $diaNo $place $canton $motiv $region $season $placeOfTaking $format $storage
    done < $CSV

}

readCSV