#!/usr/bin/env python

# Create the image data lmdb input database for testing
# ** NOTE: LeNet needs grayscale images!

import yaml
import os
import sys
import shutil
from utils.shell import run_command

# --- CONFIGURE ---

# Read in system-specific configuration values. Edit this config.yaml file before running
config = yaml.load( open('config.yaml').read() )

# convert_imageset will error out if databases already exist, so check and give the option to delete
if os.path.isdir('data/lenet_test_lmdb'):
    print
    print "WARNING: It looks like the database already exists!"
    del_db = raw_input('Do you want to delete the existing DB and continue? [y/N]: ')
    if (not del_db) or (del_db.lower() != 'y'):
        sys.exit(1)
    else:
        shutil.rmtree('data/lenet_test_lmdb')

# Make sure original image data directory is really a directory
if not os.path.isdir(config['test_image_data_root']):
    print
    print "Error: image_data_root is not a path to a directory:", image_data_root
    print "Set the image_data_root variable in config.yaml to the path where the ImageNet training data is stored."
    print
    sys.exit(1)

# Make sure train and validation split text files exist,
# otherwise the databases will get created, just with zero images
if not os.path.isfile('data/test.txt'):
    print
    print "Error: test.txt doesn't exist"
    print "Run create_test_split.py before trying to create database!"
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

print "Creating test lmdb..."
command = command_template % (config['caffe_home'], config['test_image_data_root'], 'test.txt', 'test')
run_command(command)
    
print "Done."
