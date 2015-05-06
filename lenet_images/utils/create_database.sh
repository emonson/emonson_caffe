#!/usr/bin/env sh
# Create the imagenet lmdb inputs
# N.B. set the path to the imagenet train + val data dirs
# ** NOTE: LeNet needs grayscale images!

caffe_home=/Users/emonson/Programming/caffe/build/tools
image_data_root=/Volumes/Data/Not_backed_up/ImageNet/Sets/edges_256/


if [ ! -d "$image_data_root" ]; then
  echo "Error: image_data_root is not a path to a directory: $image_data_root"
  echo "Set the image_data_root variable in create_imagenet.sh to the path" \
       "where the ImageNet training data is stored."
  exit 1
fi


echo "Creating train lmdb..."

GLOG_logtostderr=1 $caffe_home/convert_imageset \
    --resize_height=0 \
    --resize_width=0 \
    --shuffle \
    $image_data_root \
    train.txt \
    data/lenet_train_lmdb

echo "Creating val lmdb..."

GLOG_logtostderr=1 $caffe_home/convert_imageset \
    --resize_height=0 \
    --resize_width=0 \
    --shuffle \
    $image_data_root \
    val.txt \
    data/lenet_val_lmdb

echo "Done."
