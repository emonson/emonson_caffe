#!/usr/bin/env python
"""
Take a directory of ImageNet category directories and do a train / validation split
and write out train.txt and val.txt that create_database.sh needs
"""

import os
import sys
import yaml
import numpy as np
import pandas as pd
from sklearn.cross_validation import train_test_split

# --- CONFIGURE ---

# Read in system-specific configuration values. Edit this config.yaml file before running
config = yaml.load( open('config.yaml').read() )

# Make sure original image data directory is really a directory
if not os.path.isdir(config['test_image_data_root']):
    print
    print "Error: test_image_data_root is not a path to a directory:", config['test_image_data_root']
    print "Set the test_image_data_root variable in config.yaml to the path where the ImageNet training data is stored."
    sys.exit(1)


# --- RUN ---

print 'Reading image names and categories...'
# os.walk gives back a generator of tuples for each directory it walks
# ('current_dir', [directories], [files]), (...)
walk = os.walk(config['test_image_data_root'])
categories = walk.next()[1]

paths = []
cat_idxs = []

# Create list of image paths, with category directory as only prefix
for ii, category in enumerate(categories):
    file_list = walk.next()[2]
    n_files = len(file_list)
    paths.extend(['/'.join([category,filename]) for filename in file_list])
    cat_idxs.extend([ii]*n_files)


# Write out text files of file and label integer for both train and validation sets
print 'Writing\n  data/test.txt'
df = pd.DataFrame({'path':paths, 'label':[0]*len(cat_idxs)})
df[['path','label']].sort(['label','path']).to_csv('data/test.txt', sep=' ', header=None, index=None)

print '  data/test_answers.txt'
df = pd.DataFrame({'path':paths, 'label':cat_idxs})
df[['path','label']].sort(['label','path']).to_csv('data/test_answers.txt', sep=' ', header=None, index=None)

print '  data/test_categories.txt'
# Write out category names with their integer indices
df = pd.DataFrame(list(enumerate(categories)), columns=['idx','category'])
df.sort(['idx']).to_csv('data/test_categories.txt', sep='\t', header=None, index=None)
