#!/bin/bash

# --- USER-SET PARAMETERS ---

# imagesetsrootpath should point to the base Sets directory
# Within origdir should be one directory of images per category/set
# The original image file extension has to match exactly, case-sensitive

# imagesetsrootpath="/usr/local/caffe/data/CowsSailboatsWindmills"
imagesetsrootpath="/Volumes/Data/Not_backed_up/ImageNet/Sets"
# imagesetsrootpath="/Users/emonson/Data/JanBrueghel/ImageNet/Sets"

origdir="drawings_original"
origext=".png"

newsize=256
newext=".jpg"
newdir="drawings_resizedLongTile_${newsize}"


# --- SCRIPT ---

origpath=${imagesetsrootpath}/${origdir}
filematch="*${origext}"
newpath=${imagesetsrootpath}/${newdir}

# Create output directory if it doesn't exist
# (isn't strictly necessary as the first set mkdir call will create this root directory,
# too, if it doesn't exist)
mkdir -p ${newpath}

# Composing some expressions to use in convert viewport command
offset_x="%[fx: h>w ? (w*(h/${newsize})-${newsize})/2 : 0 ]"
offset_y="%[fx: h>w ? 0 : (h*(w/${newsize})-${newsize})/2 ]"
viewport="${newsize}x${newsize}+${offset_x}+${offset_y}"

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
    
    # create new set directory if it doesn't exist
    mkdir -p "${newpath}/${setname}"
    for filename in ${origpath}'/'${setname}'/'${filematch}; do
        ii=$((ii + 1))
        bn=`basename ${filename} ${origext}`
        outname="${newpath}/${setname}/${bn}${newext}"
        convert ${filename} -colorspace Gray \
            -resize ${newsize}x${newsize} \
            -set option:distort:viewport "$viewport" \
            -virtual-pixel Tile -filter point -distort SRT 0 \
            -normalize \
            ${outname}
        echo "${setname}  ${ss}/${sc}  ${ii}/${fc}  ${outname}"
    done
done
