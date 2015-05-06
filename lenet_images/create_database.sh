#!/usr/bin/env sh
# Create the imagenet lmdb inputs
# N.B. set the path to the imagenet train + val data dirs
# ** NOTE: LeNet needs grayscale images!

ORIG_DATA_ROOT=/Volumes/Data/Not_backed_up/ImageNet/Sets/edges_256/

DATA_DIR=data
CAFFE_HOME=/Users/emonson/Programming/caffe/build/tools


if [ ! -d "$ORIG_DATA_ROOT" ]; then
  echo "Error: ORIG_DATA_ROOT is not a path to a directory: $ORIG_DATA_ROOT"
  echo "Set the ORIG_DATA_ROOT variable in create_imagenet.sh to the path" \
       "where the ImageNet training data is stored."
  exit 1
fi


echo "Creating train lmdb..."

GLOG_logtostderr=1 $CAFFE_HOME/convert_imageset \
    --resize_height=0 \
    --resize_width=0 \
    --shuffle \
    $ORIG_DATA_ROOT \
    train.txt \
    $DATA_DIR/in1_train_lmdb

echo "Creating val lmdb..."

GLOG_logtostderr=1 $CAFFE_HOME/convert_imageset \
    --resize_height=0 \
    --resize_width=0 \
    --shuffle \
    $ORIG_DATA_ROOT \
    val.txt \
    $DATA_DIR/in1_val_lmdb

echo "Done."
