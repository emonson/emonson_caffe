#!/usr/bin/env python
"""
Take a directory of ImageNet category directories and do a train / validation split
and write out train.txt and val.txt that create_database.sh needs
"""

import os
import numpy as np
import pandas as pd
from sklearn.cross_validation import train_test_split

data_dir = '/Volumes/Data/Not_backed_up/ImageNet/Sets/edges_256'
RAND_STATE = 0

# os.walk gives back a generator of tuples for each directory it walks
# ('current_dir', [directories], [files]), (...)
walk = os.walk(data_dir)
categories = walk.next()[1]

paths = []
cat_idxs = []

for ii, category in enumerate(categories):
    file_list = walk.next()[2]
    n_files = len(file_list)
    paths.extend(['/'.join([category,filename]) for filename in file_list])
    cat_idxs.extend([ii]*n_files)

file_list_train, file_list_val, cat_idx_train, cat_idx_val = train_test_split( paths, cat_idxs, test_size = 0.2, random_state = RAND_STATE )

# Write out text files of file and label integer for both train and validation sets
df = pd.DataFrame({'path':file_list_train, 'label':cat_idx_train})
df[['path','label']].sort(['label','path']).to_csv('train.txt', sep=' ', header=None, index=None)

df = pd.DataFrame({'path':file_list_val, 'label':cat_idx_val})
df[['path','label']].sort(['label','path']).to_csv('val.txt', sep=' ', header=None, index=None)

# Write out category names with their integer indices
df = pd.DataFrame(list(enumerate(cats)), columns=['idx','category'])
df.sort(['idx']).to_csv('categories.txt', sep='\t', header=None, index=None)
