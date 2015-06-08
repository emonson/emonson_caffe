#!/usr/bin/env python
"""
Take a directory of ImageNet category directories and do a train / validation split
and write out train.txt and val.txt that create_database.sh needs
"""

import os
import yaml
import numpy as np
import pandas as pd
from sklearn.cross_validation import train_test_split

# --- CONFIGURE ---

# Read in system-specific configuration values. Edit this config.yaml file before running
config = yaml.load( open('config.yaml').read() )

# Make sure original image data directory is really a directory
if not os.path.isdir(config['train_image_data_root']):
    print
    print "Error: train_image_data_root is not a path to a directory:", config['train_image_data_root']
    print "Set the train_image_data_root variable in config.yaml to the path where the ImageNet training data is stored."
    sys.exit(1)

if 'data_split_rand_state' not in config:
    print "Warning: 'data_split_rand_state' not in config.yaml, so being set to default value of 0"
    config['data_split_rand_state'] = 0

if 'validation_fraction' not in config:
    print "Warning: 'validation_fraction' not in config.yaml, so being set to default value of 0.2"
    config['validation_fraction'] = 0.2


# --- RUN ---

print 'Reading image names and categories...'
# os.walk gives back a generator of tuples for each directory it walks
# ('current_dir', [directories], [files]), (...)
walk = os.walk(config['train_image_data_root'])
categories = walk.next()[1]

paths = []
cat_idxs = []

# Create list of image paths, with category directory as only prefix
for ii, category in enumerate(categories):
    file_list = walk.next()[2]
    n_files = len(file_list)
    paths.extend(['/'.join([category,filename]) for filename in file_list])
    cat_idxs.extend([ii]*n_files)

# Run actual train/test split
file_list_train, file_list_val, cat_idx_train, cat_idx_val = \
        train_test_split( paths, cat_idxs, \
                            test_size = config['validation_fraction'], \
                            random_state = config['data_split_rand_state'] )

# Write out text files of file and label integer for both train and validation sets
print 'Writing\n  data/train.txt'
df = pd.DataFrame({'path':file_list_train, 'label':cat_idx_train})
df[['path','label']].sort(['label','path']).to_csv('data/train.txt', sep=' ', header=None, index=None)

print '  data/val.txt'
df = pd.DataFrame({'path':file_list_val, 'label':cat_idx_val})
df[['path','label']].sort(['label','path']).to_csv('data/val.txt', sep=' ', header=None, index=None)

print '  data/categories.txt'
# Write out category names with their integer indices
df = pd.DataFrame(list(enumerate(categories)), columns=['idx','category'])
df.sort(['idx']).to_csv('data/categories.txt', sep='\t', header=None, index=None)
