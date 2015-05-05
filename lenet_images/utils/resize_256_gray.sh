#!/bin/bash

# databasepath should point to the base Sets directory
databasepath="/Volumes/Data/Not_backed_up/ImageNet/Sets"

# Within origdir should be one directory of images per category/set
origdir="originals"
# This extension has to match exactly, case-sensitive
origext=".JPEG"
origpath=${databasepath}/${origdir}
filematch="*${origext}"

newsize=256
newdir="resized_gray_${newsize}"
newext=".jpg"
newpath=${databasepath}/${origdir}

# Create output directory if it doesn't exist
mkdir -p ${newdir}

# count the number of sets
setcount=`find $origpath -maxdepth 1 -type d | wc -l`
sc=$((setcount - 1))
ss=0

# Find all subdirectories of origdir, each of which will be a category label
for setpath in ${origpath}/*/; do
    setname=`basename ${setpath}`
    ss=$((ss + 1))
    
    # count number of image files in this set
    filecount=`find $origpath/$setname -maxdepth 1 -name "$filematch" | wc -l`
    fc=$((filecount + 0))
    ii=0
    
    mkdir -p "${newpath}/${setname}"
    for filename in ${origpath}'/'${setname}'/'${filematch}; do
        ii=$((ii + 1))
        bn=`basename ${filename} ${origext}`
        outname="${newpath}/${setname}/${bn}${newext}"
        convert ${filename} -colorspace Gray \
                             -resize ${newsize}x${newsize}^ \
                             -gravity center -extent ${newsize}x${newsize} \
                ${outname}
        echo "${setname}  ${ss}/${sc}  ${ii}/${fc}  ${outname}"
    done
done
