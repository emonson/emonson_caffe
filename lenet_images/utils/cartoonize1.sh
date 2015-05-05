#!/bin/bash

# This should be run from the base Sets directory

outsize=256
origdir="originals"
outdir="edges_${outsize}"
filematch='*.JPEG'

mkdir -p ${outdir}

# count the number of sets
setcount=`find ./$origdir -maxdepth 1 -type d | wc -l`
sc=$((setcount - 1))
ss=0

# Find all subdirectories of origdir, each of which will be a category label
for setpath in ${origdir}/*/; do
    setname=`basename ${setpath}`
    ss=$((ss + 1))
    
    # count number of image files in this set
    filecount=`find ./$origdir/$setname -maxdepth 1 -name "$filematch" | wc -l`
    fc=$((filecount + 0))
    ii=0
    
    mkdir -p "${outdir}/${setname}"
    for filename in ${origdir}'/'${setname}'/'${filematch}; do
        ii=$((ii + 1))
        bn=`basename ${filename} .JPEG`
        outname="${outdir}/${setname}/${bn}.jpg"
        convert ${filename} -colorspace Gray \
                             -resize ${outsize}x${outsize}^ \
                             -gravity center -extent ${outsize}x${outsize} \
                             -blur 2 \
                \( +clone -negate -blur 2 \) -compose color-dodge -composite \
                \( +clone \) -compose multiply -composite \
                \( +clone \) -compose multiply -composite \
                \( +clone \) -compose multiply -composite \
                ${outname}
        echo "${setname}  ${ss}/${sc}  ${ii}/${fc}  ${outname}"
    done
done
