#!/usr/bin/env python

# Create the image data lmdb input database for training and validation
# ** NOTE: LeNet needs grayscale images!

import yaml
import os
import sys
from utils.shell import run_command

# --- CONFIGURE ---

# Read in system-specific configuration values. Edit this config.yaml file before running
config = yaml.load( open('config.yaml').read() )

# convert_imageset will error out if databases already exist, so check and be more graceful
if os.path.isdir('data/lenet_train_lmdb') or os.path.isdir('data/lenet_val_lmdb'):
    print
    print "Error: It looks like the database already exists!"
    print "Delete both data/lenet_train_lmdb and data/lenet_val_lmdb directories and run this script again."
    print
    sys.exit(1)

# Make sure original image data directory is really a directory
if not os.path.isdir(config['image_data_root']):
    print
    print "Error: image_data_root is not a path to a directory:", image_data_root
    print "Set the image_data_root variable in config.yaml to the path where the ImageNet training data is stored."
    print
    sys.exit(1)

# Make train and validation split text files exist,
# otherwise the databases will get created, just with zero images
if not (os.path.isfile('data/train.txt') and os.path.isfile('data/val.txt')):
    print
    print "Error: Training and/or validation files, data/train.txt and data/val.txt don't exist"
    print "Run create_train_val_split.py before trying to create database!"
    print
    sys.exit(1)

# Create a template string for the shell command to feed values into
# Note: Data directory path string needs a slash after it, so we're adding it here explicitly
command_template = """
GLOG_logtostderr=1 %s/convert_imageset \
    --resize_height=0 \
    --resize_width=0 \
    --shuffle \
    %s/ \
    data/%s \
    data/lenet_%s_lmdb
"""


# --- RUN ---

print "Creating train lmdb..."
command = command_template % (config['caffe_home'], config['image_data_root'], 'train.txt', 'train')
run_command(command)
    
print "Creating val lmdb..."
command = command_template % (config['caffe_home'], config['image_data_root'], 'val.txt', 'val')
run_command(command)

print "Done."
