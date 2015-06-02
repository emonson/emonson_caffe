#!/bin/bash

# --- USER-SET PARAMETERS ---

# Loading base directory for image sets from server.conf file

CONFIG_FILE=server.conf

if [[ -f $CONFIG_FILE ]]; then
    . $CONFIG_FILE
else
    echo "Error: config file can't be found."
    echo $CONFIG_FILE
    exit 1
fi

origdir="originals"
origext=".JPEG"

newsize=256
newext=".jpg"


# --- SCRIPT ---

origpath=${IMAGESETSROOTPATH}/${origdir}
filematch="*${origext}"
newdir="resized_gray_${newsize}"
newpath=${IMAGESETSROOTPATH}/${newdir}

# Create output directory if it doesn't exist
# (isn't strictly necessary as the first set mkdir call will create this root directory,
# too, if it doesn't exist)
mkdir -p ${newpath}

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
                             -resize ${newsize}x${newsize}^ \
                             -gravity center -extent ${newsize}x${newsize} \
                ${outname}
        echo "${setname}  ${ss}/${sc}  ${ii}/${fc}  ${outname}"
    done
done
